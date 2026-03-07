# 数据库设计规范

## 命名规范

### 表名
- 使用 snake_case，全小写
- 格式：`{业务前缀}_{模块}_{表类型}`
- 示例：`tg_merchant_info`（托管商家主表）、`tg_merchant_shipping_detail`（发货明细表）、`tg_merchant_operate_log`（操作日志表）

### 字段名
- 使用 snake_case，全小写
- 示例：`customer_code`、`create_time`、`is_deleted`

### 索引名
- 普通索引：`idx_{表名简写}_{字段名}`
- 唯一索引：`uk_{表名简写}_{字段名}`
- 示例：`idx_merchant_customer_code`、`uk_merchant_site_relation`

## 必备字段

每张表必须包含以下字段：

```sql
id              BIGINT          NOT NULL AUTO_INCREMENT COMMENT '主键ID',
gmt_create      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
gmt_modified    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
creator         VARCHAR(64)     DEFAULT NULL COMMENT '创建人',
modifier        VARCHAR(64)     DEFAULT NULL COMMENT '更新人',
is_deleted      TINYINT         NOT NULL DEFAULT 0 COMMENT '是否删除：0-否，1-是',
PRIMARY KEY (id)
```

## 表结构模板

### 主表模板

```sql
CREATE TABLE `{业务前缀}_{实体}_info` (
    `id`                    BIGINT          NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    -- 业务字段
    `customer_code`         VARCHAR(64)     NOT NULL COMMENT '客户编码',
    `customer_name`         VARCHAR(128)    DEFAULT NULL COMMENT '客户名称',
    `status`                TINYINT         NOT NULL DEFAULT 1 COMMENT '状态：1-生效，0-失效',
    -- 必备字段
    `gmt_create`            DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `gmt_modified`          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `creator`               VARCHAR(64)     DEFAULT NULL COMMENT '创建人',
    `modifier`              VARCHAR(64)     DEFAULT NULL COMMENT '更新人',
    `is_deleted`            TINYINT         NOT NULL DEFAULT 0 COMMENT '是否删除：0-否，1-是',
    PRIMARY KEY (`id`),
    KEY `idx_customer_code` (`customer_code`),
    KEY `idx_gmt_create` (`gmt_create`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='{实体}主表';
```

### 明细表模板

```sql
CREATE TABLE `{业务前缀}_{实体}_detail` (
    `id`                    BIGINT          NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    -- 关联字段
    `main_id`               BIGINT          NOT NULL COMMENT '主表ID',
    `stat_date`             DATE            NOT NULL COMMENT '统计日期',
    -- 业务字段
    `quantity`              INT             NOT NULL DEFAULT 0 COMMENT '数量',
    `amount`                DECIMAL(12,2)   DEFAULT NULL COMMENT '金额',
    -- 必备字段
    `gmt_create`            DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `gmt_modified`          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    KEY `idx_main_id` (`main_id`),
    KEY `idx_stat_date` (`stat_date`),
    UNIQUE KEY `uk_main_stat` (`main_id`, `stat_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='{实体}明细表';
```

### 操作日志表模板

```sql
CREATE TABLE `{业务前缀}_{实体}_operate_log` (
    `id`                    BIGINT          NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    -- 关联字段
    `biz_id`                BIGINT          NOT NULL COMMENT '业务ID',
    `biz_type`              VARCHAR(32)     NOT NULL COMMENT '业务类型',
    -- 日志字段
    `operate_type`          VARCHAR(32)     NOT NULL COMMENT '操作类型：ADD-新增，UPDATE-更新，DELETE-删除',
    `operate_content`       VARCHAR(512)    DEFAULT NULL COMMENT '操作内容',
    `operator`              VARCHAR(64)     NOT NULL COMMENT '操作人',
    `operator_name`         VARCHAR(64)     DEFAULT NULL COMMENT '操作人姓名',
    `operate_time`          DATETIME        NOT NULL COMMENT '操作时间',
    -- 必备字段
    `gmt_create`            DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    KEY `idx_biz_id` (`biz_id`),
    KEY `idx_operate_time` (`operate_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='{实体}操作日志表';
```

## 常用字段类型

| 场景 | 字段类型 | 示例 |
|-----|---------|-----|
| 主键 | BIGINT | id |
| 编码类 | VARCHAR(64) | customer_code, site_code |
| 名称类 | VARCHAR(128) | customer_name, site_name |
| 状态/枚举 | TINYINT | status, is_deleted |
| 数量 | INT | quantity, count |
| 金额 | DECIMAL(12,2) | amount, price |
| 日期 | DATE | stat_date, biz_date |
| 时间 | DATETIME | create_time, operate_time |
| 长文本 | TEXT | remark, description |

## 索引设计原则

1. **主键索引**：每张表必须有主键，推荐自增 BIGINT
2. **查询条件**：WHERE 条件中的字段需要建索引
3. **联合索引**：遵循最左前缀原则，把区分度高的字段放前面
4. **唯一约束**：业务上唯一的组合建唯一索引
5. **避免过多**：单表索引不超过 5 个

## 示例：托管商家表设计

```sql
-- 商家主表
CREATE TABLE `tg_merchant_info` (
    `id`                    BIGINT          NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `sto_customer_code`     VARCHAR(64)     NOT NULL COMMENT '申通客户编码',
    `sto_customer_name`     VARCHAR(128)    DEFAULT NULL COMMENT '申通客户名称',
    `ec_customer_code`      VARCHAR(64)     DEFAULT NULL COMMENT '电商客户编码',
    `ec_customer_name`      VARCHAR(128)    DEFAULT NULL COMMENT '电商客户名称',
    `customer_type`         VARCHAR(32)     DEFAULT NULL COMMENT '客户类型：PDD-拼多多，DOUYIN-抖音',
    `order_site_code`       VARCHAR(32)     DEFAULT NULL COMMENT '订单网点编码',
    `order_site_name`       VARCHAR(64)     DEFAULT NULL COMMENT '订单网点名称',
    `shipping_site_code`    VARCHAR(32)     NOT NULL COMMENT '发货网点编码',
    `shipping_site_name`    VARCHAR(64)     DEFAULT NULL COMMENT '发货网点名称',
    `hosting_center`        VARCHAR(32)     DEFAULT NULL COMMENT '托管中心：NANNING-南宁，JIAN-吉安，NEIJIANG-内江',
    `service_status`        TINYINT         NOT NULL DEFAULT 1 COMMENT '服务状态：1-服务中，2-停止服务，3-不服务',
    `first_entry_time`      DATETIME        DEFAULT NULL COMMENT '首次入表时间',
    `last_shipping_date`    DATE            DEFAULT NULL COMMENT '最后发货日期',
    `gmt_create`            DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `gmt_modified`          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `creator`               VARCHAR(64)     DEFAULT NULL COMMENT '创建人',
    `modifier`              VARCHAR(64)     DEFAULT NULL COMMENT '更新人',
    `is_deleted`            TINYINT         NOT NULL DEFAULT 0 COMMENT '是否删除：0-否，1-是',
    PRIMARY KEY (`id`),
    KEY `idx_sto_customer_code` (`sto_customer_code`),
    KEY `idx_shipping_site_code` (`shipping_site_code`),
    KEY `idx_hosting_center` (`hosting_center`),
    KEY `idx_service_status` (`service_status`),
    UNIQUE KEY `uk_customer_shipping_site` (`sto_customer_code`, `shipping_site_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='托管商家主表';

-- 发货量明细表
CREATE TABLE `tg_merchant_shipping_detail` (
    `id`                    BIGINT          NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `merchant_id`           BIGINT          NOT NULL COMMENT '商家ID',
    `stat_date`             DATE            NOT NULL COMMENT '统计日期',
    `total_shipping_qty`    INT             NOT NULL DEFAULT 0 COMMENT '总发货量',
    `hosting_shipping_qty`  INT             NOT NULL DEFAULT 0 COMMENT '托管发货量',
    `gmt_create`            DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `gmt_modified`          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    KEY `idx_merchant_id` (`merchant_id`),
    KEY `idx_stat_date` (`stat_date`),
    UNIQUE KEY `uk_merchant_stat_date` (`merchant_id`, `stat_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商家发货量明细表';

-- 操作日志表
CREATE TABLE `tg_merchant_operate_log` (
    `id`                    BIGINT          NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `merchant_id`           BIGINT          NOT NULL COMMENT '商家ID',
    `operate_type`          VARCHAR(32)     NOT NULL COMMENT '操作类型：ADD-添加商家，STOP-停止服务，START-开启服务，UPDATE_CENTER-调整托管中心',
    `operate_content`       VARCHAR(512)    DEFAULT NULL COMMENT '操作内容',
    `operator`              VARCHAR(64)     NOT NULL COMMENT '操作人',
    `operator_name`         VARCHAR(64)     DEFAULT NULL COMMENT '操作人姓名',
    `operate_time`          DATETIME        NOT NULL COMMENT '操作时间',
    `gmt_create`            DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    KEY `idx_merchant_id` (`merchant_id`),
    KEY `idx_operate_time` (`operate_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商家操作日志表';
```
