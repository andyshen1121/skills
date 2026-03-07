---
name: aliyun-bill-analysis
description: 当用户提供阿里云产品日粒度账单 CSV 文件时触发，用于分析每日费用明细、各计费项汇总、存储类型分布、月度对比等。账单文件名通常包含"日粒度账单"字样。
---

# 阿里云账单分析

## Python 环境

Vault 数据分析目录下有共享 venv，直接使用：

```bash
# venv 路径
/Users/sto/Documents/文稿 - sto的Mac mini/Obsidian Vault/数据分析/.venv/bin/python3

# 如需安装新依赖
cd "/Users/sto/Documents/文稿 - sto的Mac mini/Obsidian Vault/数据分析"
uv pip install pandas openpyxl
```

## 日粒度账单 CSV 结构

关键列：

| 列名 | 说明 |
|------|------|
| `账单日期` | 格式 YYYY-MM-DD |
| `计费项` | 具体费用类型（存储容量、流量、请求次数等）|
| `应付金额` | 实际应付（优惠后），分析用此列 |
| `目录总价` | 原价 |
| `优惠金额` | 折扣金额 |
| `用量` / `用量单位` | 实际用量 |
| `资产/资源实例ID` | 格式 `cn-shanghai;archive`，分号后为存储类型 |

**提取存储类型：**
```python
df['存储类型'] = df['资产/资源实例ID'].str.extract(r';(\w+)$')
type_map = {'standard': '标准存储', 'archive': '归档存储', 'IA': '低频存储'}
df['存储类型中文'] = df['存储类型'].map(type_map).fillna(df['存储类型'])
```

## OSS 计费项中文映射

```python
col_map = {
    '低频访问(本地冗余)/归档存储容量': '归档/低频容量',
    '标准存储（本地冗余）容量': '标准存储容量',
    '外网流出流量': '外网流出',
    'PUT类和其他请求次数': 'PUT请求',
    '归档直读数据取回容量': '归档直读',
    'GET类请求次数': 'GET请求',
    '低频(本地冗余)/归档保留不足规定时长计费项（容量*小时数）': '保留不足',
    '高级图片处理(低)': '图片处理',
}
```

## 标准分析流程

### 1. 读取数据

```python
import pandas as pd
df = pd.read_csv("账单文件.csv")
# 注意：文件行数多时用 wc -l 确认，pd.read_csv 默认可能因编码截断
```

### 2. 每日费用透视表

```python
pivot = df.pivot_table(
    index='账单日期',
    columns='计费项',
    values='应付金额',
    aggfunc='sum'
).round(2).fillna(0)
pivot.columns = [col_map.get(c, c) for c in pivot.columns]
pivot = pivot.loc[:, (pivot != 0).any(axis=0)]  # 去掉全零列
pivot['合计'] = pivot.sum(axis=1).round(2)
```

### 3. 计费项月度汇总

```python
item_total = df.groupby('计费项').agg(
    应付金额=('应付金额', 'sum'),
    目录总价=('目录总价', 'sum'),
    优惠金额=('优惠金额', 'sum'),
).reset_index()
item_total['占比%'] = (item_total['应付金额'] / item_total['应付金额'].sum() * 100).round(2)
item_total = item_total.sort_values('应付金额', ascending=False)
```

### 4. 存储类型汇总

```python
type_total = df.groupby('存储类型中文')['应付金额'].sum().round(2).sort_values(ascending=False)
```

## 输出规范

**默认只输出对话中的 Markdown 表格，不生成文件。**

仅当用户明确要求"保存"、"导出 Excel"、"生成文件"时，才输出 xlsx：

```python
output = "产品账单分析_YYYYMMDD.xlsx"
with pd.ExcelWriter(output, engine='openpyxl') as writer:
    pivot.reset_index().to_excel(writer, sheet_name='每日明细', index=False)
    item_total.to_excel(writer, sheet_name='计费项汇总', index=False)
    type_total.reset_index().to_excel(writer, sheet_name='存储类型汇总', index=False)
```

文件命名：`产品_账单分析_YYYYMMDD.xlsx`，例如 `OSS账单分析_20260304.xlsx`

## 分析维度清单

- [ ] 总费用（应付金额、目录总价、优惠折扣率）
- [ ] 每日费用趋势（是否有异常峰值）
- [ ] 计费项分布及占比
- [ ] 存储类型分布（OSS 特有）
- [ ] 多月对比（日均费用横向比较）
- [ ] 异常日检测（PUT 请求异常、单日费用明显偏高）

## 常见异常模式（OSS）

| 异常现象 | 可能原因 |
|----------|----------|
| PUT 请求某天突增 10-200 倍 | 批量数据写入或迁移操作 |
| 标准存储容量骤降 + 归档容量骤升 | 存储类型迁移（归档化降本）|
| 某日费用仅为正常值的 30-50% | 账单数据不完整，需确认 |
| 归档直读取回费用突增 | 大量归档文件被读取，考虑预取方案 |

## 多月对比模板

```python
summary = []
for label, df_ in months.items():
    daily_avg = df_['应付金额'].sum() / df_['账单日期'].nunique()
    summary.append({'月份': label, '日均费用': round(daily_avg, 2), ...})
pd.DataFrame(summary)
```

## 注意事项

- CSV 文件较大（>64k token）时，直接用 Python 读取，不要用 Read 工具
- `资产/资源实例ID` 列格式为 `地域;存储类型`，正则提取分号后内容
- 多月对比时对齐"日均费用"而非总费用（各月天数不同）
- 账单末尾日期费用偏低时，先确认是否为数据截断再下结论
