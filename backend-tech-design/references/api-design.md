# 接口设计规范

## RESTful 规范

### HTTP 方法
- **GET**：查询操作（列表查询、详情查询）
- **POST**：写操作（新增、修改、删除、批量操作）

### URL 规范
- 使用小写字母和连字符
- 资源用名词复数
- 格式：`/api/{模块}/{资源}/{操作}`

```
GET  /api/merchant/list          # 商家列表
GET  /api/merchant/detail/{id}   # 商家详情
POST /api/merchant/add           # 新增商家
POST /api/merchant/update        # 更新商家
POST /api/merchant/delete        # 删除商家
POST /api/merchant/stop-service  # 停止服务
```

## 统一响应格式

```java
public class Result<T> {
    private Integer code;    // 状态码：200-成功，其他-失败
    private String message;  // 提示信息
    private T data;          // 返回数据
}
```

成功响应：
```json
{
    "code": 200,
    "message": "success",
    "data": { ... }
}
```

失败响应：
```json
{
    "code": 500,
    "message": "商家已存在，请不要重复添加",
    "data": null
}
```

## 分页参数

### 请求参数
```java
public class PageRequest {
    private Integer pageNum = 1;   // 页码，从1开始
    private Integer pageSize = 20; // 每页条数，默认20
}
```

### 响应格式
```java
public class PageResult<T> {
    private List<T> list;       // 数据列表
    private Long total;         // 总条数
    private Integer pageNum;    // 当前页码
    private Integer pageSize;   // 每页条数
    private Integer pages;      // 总页数
}
```

## 接口文档模板

### 列表查询接口

```markdown
#### 商家列表查询

**接口地址**：GET /api/merchant/list

**请求参数**：

| 参数 | 类型 | 必填 | 说明 |
|-----|------|-----|------|
| customerName | String | 否 | 商家名称，模糊查询 |
| customerCode | String | 否 | 商家编码，精确查询 |
| shippingSiteCode | String | 否 | 发货网点编码 |
| hostingCenter | String | 否 | 托管中心：NANNING/JIAN/NEIJIANG |
| serviceStatus | Integer | 否 | 服务状态：1-服务中，2-停止服务，3-不服务 |
| lastShippingDateStart | Date | 否 | 最后发货开始日期 |
| lastShippingDateEnd | Date | 否 | 最后发货结束日期 |
| pageNum | Integer | 否 | 页码，默认1 |
| pageSize | Integer | 否 | 每页条数，默认20 |

**响应参数**：

| 参数 | 类型 | 说明 |
|-----|------|------|
| list | List | 商家列表 |
| list[].id | Long | 商家ID |
| list[].customerName | String | 商家名称 |
| list[].customerCode | String | 商家编码 |
| list[].serviceStatus | Integer | 服务状态 |
| list[].hostingCenter | String | 托管中心 |
| list[].lastMonthAvgQty | Integer | 上月日均托管量 |
| list[].lastShippingDate | Date | 最后发货日期 |
| total | Long | 总条数 |

**响应示例**：
```json
{
    "code": 200,
    "message": "success",
    "data": {
        "list": [
            {
                "id": 1,
                "customerName": "XX电商",
                "customerCode": "C001",
                "serviceStatus": 1,
                "hostingCenter": "NANNING",
                "lastMonthAvgQty": 1500,
                "lastShippingDate": "2024-01-15"
            }
        ],
        "total": 100,
        "pageNum": 1,
        "pageSize": 20
    }
}
```
```

### 详情查询接口

```markdown
#### 商家详情查询

**接口地址**：GET /api/merchant/detail/{id}

**路径参数**：

| 参数 | 类型 | 必填 | 说明 |
|-----|------|-----|------|
| id | Long | 是 | 商家ID |

**响应参数**：

| 参数 | 类型 | 说明 |
|-----|------|------|
| id | Long | 商家ID |
| customerName | String | 商家名称 |
| customerCode | String | 商家编码 |
| ... | ... | ... |
| shippingList | List | 发货量列表 |
| logList | List | 操作日志列表 |
```

### 新增接口

```markdown
#### 添加新商家

**接口地址**：POST /api/merchant/add

**请求参数**：

| 参数 | 类型 | 必填 | 说明 |
|-----|------|-----|------|
| hostingCenter | String | 是 | 托管中心 |
| customerCode | String | 是 | 商家编码 |
| shippingSiteCode | String | 是 | 发货网点编码 |

**请求示例**：
```json
{
    "hostingCenter": "NANNING",
    "customerCode": "C001",
    "shippingSiteCode": "030001"
}
```

**响应示例**：
```json
{
    "code": 200,
    "message": "添加成功",
    "data": null
}
```

**业务校验**：
- 发货网点不在托管生效范围时，返回：「网点当前未托管，请重新选择」
- 发货网点+商家已存在时，返回：「商家已存在，请不要重复添加」
```

### 状态变更接口

```markdown
#### 停止服务

**接口地址**：POST /api/merchant/stop-service

**请求参数**：

| 参数 | 类型 | 必填 | 说明 |
|-----|------|-----|------|
| id | Long | 是 | 商家ID |

**业务校验**：
- 校验商家是否在服务中，不在则返回：「商家已停止，无需重复操作」

**响应示例**：
```json
{
    "code": 200,
    "message": "操作成功",
    "data": null
}
```
```

## 接口列表模板

```markdown
## 接口列表

| 接口 | 方法 | URL | 说明 |
|-----|------|-----|------|
| 商家列表 | GET | /api/merchant/list | 分页查询商家列表 |
| 商家详情 | GET | /api/merchant/detail/{id} | 查询商家详情 |
| 添加商家 | POST | /api/merchant/add | 手动添加新商家 |
| 停止服务 | POST | /api/merchant/stop-service | 停止商家服务 |
| 开启服务 | POST | /api/merchant/start-service | 开启商家服务 |
| 导出商家 | GET | /api/merchant/export | 导出商家数据 |
```

## Controller 代码模板

```java
@RestController
@RequestMapping("/api/merchant")
public class MerchantController {

    @Autowired
    private MerchantService merchantService;

    /**
     * 商家列表查询
     */
    @GetMapping("/list")
    public Result<PageResult<MerchantVO>> list(MerchantQueryDTO query) {
        return Result.success(merchantService.listByPage(query));
    }

    /**
     * 商家详情
     */
    @GetMapping("/detail/{id}")
    public Result<MerchantDetailVO> detail(@PathVariable Long id) {
        return Result.success(merchantService.getDetail(id));
    }

    /**
     * 添加商家
     */
    @PostMapping("/add")
    public Result<Void> add(@RequestBody @Valid MerchantAddDTO dto) {
        merchantService.add(dto);
        return Result.success();
    }

    /**
     * 停止服务
     */
    @PostMapping("/stop-service")
    public Result<Void> stopService(@RequestBody @Valid IdDTO dto) {
        merchantService.stopService(dto.getId());
        return Result.success();
    }
}
```

## DTO/VO 命名规范

| 类型 | 命名 | 说明 |
|-----|------|------|
| 查询参数 | XxxQueryDTO | 列表查询参数 |
| 新增参数 | XxxAddDTO | 新增接口参数 |
| 更新参数 | XxxUpdateDTO | 更新接口参数 |
| 列表返回 | XxxVO | 列表项 |
| 详情返回 | XxxDetailVO | 详情数据 |
