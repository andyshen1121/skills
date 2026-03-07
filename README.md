# Skills 仓库说明

本仓库用于集中管理 `~/.claude/skills` 下的技能文件。

## 场景导航（推荐）

### 投资研究与交易
- `tech-earnings-deepdive`：科技股财报深度分析
- `us-market-sentiment`：美股市场情绪监控与仓位建议
- `us-value-investing`：美股价值投资分析
- `macro-liquidity`：宏观流动性监控与风险预警

### 开发与技术设计
- `backend-tech-design`：后端技术方案设计（架构/API/数据库）
- `planning-with-files`：基于文件的任务规划与执行管理
- `prompt-optimizer`：提示词优化与改写

### 知识管理与效率
- `obsidian-diary`：Obsidian 日记记录与归档
- `save-to-obsidian`：内容保存到 Obsidian
- `skill-sync`：Skill 同步与分发

### 云资源与成本
- `aliyun-bill-analysis`：阿里云账单分析与成本优化

## Skills 清单（完整）

| Skill 目录 | 所属场景 | 中文功能描述 | 原始描述 |
|---|---|---|---|
| `aliyun-bill-analysis` | 云资源与成本 | 阿里云账单分析与成本优化 | 当用户提供阿里云产品日粒度账单 CSV 文件时触发，用于分析每日费用明细、各计费项汇总、存储类型分布、月度对比等。账单文件名通常包含"日粒度账单"字样。 |
| `backend-tech-design` | 开发与技术设计 | 后端技术方案设计（架构/API/数据库） | 后端技术方案设计与文档输出。适用场景：(1) 根据 PRD/需求文档输出完整技术方案 (2) 设计数据库表结构 (3) 设计 RESTful 接口 (4) 设计数据同步方案。技术栈：Spring Boot + MyBatis-Plus，阿里云全家桶（PolarDB、ODPS/DataWorks、RocketMQ、Redis、ES）。当用户说「帮我写技术方案」「设计表结构」「这个接口怎么设计」或上传 PRD 文档时触发。 |
| `macro-liquidity` | 投资研究与交易 | 宏观流动性监控与风险预警 | 宏观流动性监控与风险预警系统。通过追踪4大核心指标（美联储净流动性、SOFR隔夜融资利率、MOVE美债波动率指数、日元套利交易信号）实时评估全球金融体系的流动性状态，输出流动性评级和风险应对建议。当用户提到流动性、美联储缩表、TGA账户、逆回购ON RRP、SOFR利率、MOVE指数、美债波动、日元套利carry trade、USDJPY与利差、缩表对市场影响、钱紧不紧、流动性拐点、金融条件收紧等话题时，务必使用此技能。即使用户只是笼统地问"现在流动性怎么样"或"美联储在抽水还是放水"，也应触发此技能来提供结构化的分析框架。 |
| `obsidian-diary` | 知识管理与效率 | Obsidian 日记记录与归档 | 用于在 Obsidian vault 中生成每日日记条目。当用户想记录今天的工作、扫描 vault 修改文件生成日志、或自动生成每日复盘时触发。 |
| `planning-with-files` | 开发与技术设计 | 基于文件的任务规划与执行管理 | Implements Manus-style file-based planning for complex tasks. Creates task_plan.md, findings.md, and progress.md. Use when starting complex multi-step tasks, research projects, or any task requiring >5 tool calls. |
| `prompt-optimizer` | 开发与技术设计 | 提示词优化与改写 | 提示词优化专家工具，专注于物流行业智能外呼机器人场景的提示词优化。适用场景：(1) 客诉工单核实诉求的外呼对话优化 (2) 客诉工单安抚用户情绪的外呼对话优化。当用户请求优化提示词、改进 prompt、提升对话效果、解决 bad case 时触发此 skill。 |
| `save-to-obsidian` | 知识管理与效率 | 内容保存到 Obsidian | 用于将分析报告、研究摘要、财务分析、技术文档保存到 Obsidian vault。当用户完成分析后想存档、或说"保存到 vault/Obsidian"时触发。 |
| `skill-sync` | 知识管理与效率 | Skill 同步与分发 | 当用户提到"同步 skill"、"把 skill 同步到其他工具"、"sync skill to codex/openclaw"、"skill 同步"、"发布 skill"、"让其他 AI 工具也能用这个 skill"时触发。负责将 Claude Code skills 同步到 Codex 和 OpenClaw，处理各工具间的 frontmatter 格式差异。 |
| `tech-earnings-deepdive` | 投资研究与交易 | 科技股财报深度分析 | 科技股财报深度分析与多视角投资备忘录系统（v3.0）。覆盖A-P共16大分析模块、6大投资哲学视角、机构级证据标准、反偏见框架和可执行决策体系。当用户提到某科技公司财报分析、季报/年报解读、earnings call、收入增长分析、利润率变化、guidance指引、估值模型、DCF、反向DCF、EV/EBITDA、PEG、Rule of 40、管理层分析、竞争格局、持仓判断、是否买入/卖出/加仓某科技股、某公司最新财报怎么看、帮我做个deep dive、多角度估值、投资大师怎么看这家公司、variant view、key forces、kill conditions、筹码分布、高管团队、合作伙伴生态、宏观政策影响等话题时，务必使用此技能。即使用户只是笼统地问"帮我看看NVDA最新财报"或"META这季度表现如何"或"该不该继续持有MSFT"，也应触发此技能来提供全面的财报分析和多视角投资备忘录。此技能与us-value-investing技能互补——us-value-investing侧重长期价值四维评分，本技能侧重最新财报的深度拆解、多投资哲学的综合判断、以及可执行的持仓决策。 |
| `us-market-sentiment` | 投资研究与交易 | 美股市场情绪监控与仓位建议 | 美股市场情绪监控与仓位建议系统。通过追踪5大核心指标（NAAIM暴露指数、机构股票配置比例、散户净买入额、标普500远期市盈率、对冲基金杠杆率）评估市场情绪状态，输出情绪评级和仓位建议。当用户提到美股情绪、市场过热、贪婪恐慌指标、NAAIM、机构持仓、散户情绪、市盈率估值泡沫、对冲基金杠杆、是否该减仓、市场风险评估、仓位管理建议、市场顶部/底部信号等话题时，务必使用此技能。即使用户只是笼统地问"美股现在风险大不大"或"该不该减仓"，也应触发此技能来提供结构化的分析框架。 |
| `us-value-investing` | 投资研究与交易 | 美股价值投资分析 | 美股价值投资分析框架。通过4大核心维度（ROE持续性、负债安全性、自由现金流质量、护城河评估）对上市公司进行系统性价值评估，输出投资评级和分析理由。当用户提到某只美股是否值得长期持有、公司基本面分析、ROE分析、负债率评估、自由现金流、护城河、巴菲特选股、价值投资筛选、某公司财报怎么看、某股票估值是否合理等话题时，务必使用此技能。即使用户只是笼统地问"XX这只股票怎么样"或"帮我分析一下XX的基本面"，也应触发此技能来提供结构化的价值投资分析框架。 |

## 使用方式

1. 每个 skill 目录通常包含 `SKILL.md`（核心定义）及可选脚本/模板。
2. 根据任务场景选择对应 skill，并按 `SKILL.md` 指引执行。
3. 建议通过 PR 维护，确保描述和实现同步更新。

## 维护建议

- 新增 skill 时请补充中文描述与所属场景。
- 变更行为时同步更新 `SKILL.md` 与本 README。
- 涉及凭证/密钥的内容不要入库。