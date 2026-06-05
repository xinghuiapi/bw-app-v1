# bw-pc-api-v2（适配h5）接口文档

> 从 `接口文档.md` 中筛选生成，仅包含 `bw-pc-api-v2（适配h5）` 分组下的接口。

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-04-13 11:11:31

> 更新时间: 2025-10-26 00:34:46

**请在所有api请求头添加参数    lang 参数，值为语系代码
所有api请求除 获取全局参数接口以外，其他接口请求都要在路由结尾带上 ?lang=语系代码**

**目录Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| 暂无参数 |

**目录Query参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| 暂无参数 |

**目录Body参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| 暂无参数 |

**目录认证信息**

> 继承父级

**Query**

### 登陆/注册

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-04-13 11:11:31

> 更新时间: 2025-04-13 11:11:31

**请在所有api请求头添加参数    lang 参数，值为语系代码**

**目录Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| 暂无参数 |

**目录Query参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| 暂无参数 |

**目录Body参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| 暂无参数 |

**目录认证信息**

> 继承父级

**Query**

#### 会员登陆

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-04-13 11:11:31

> 更新时间: 2026-03-23 12:58:47

```text
暂无描述
```

**接口状态**

> 已完成

**接口URL**

> http://45.200.16.18:60000/api/user/login

**请求方式**

> POST

**Content-Type**

> json

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| lang | CN | string | 是 | - |

**请求Body参数**

```javascript
{
    "type": 1,
    "username": "dd4647",
    "password": "qq123456",
    "captcha_code": "",
    "captcha_key": "",
    "email": "123132123@qq.com",
    "email_code": "279911",
    "phone": "13145678949",
    "area_code": "+86",
    "phone_code": "123456"
}
```

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| type | 2 | number | 是 | 登陆类型：1普通登陆，2邮箱登录，3手机号登陆 |
| username | ceshi123 | string | 是 | 账号/邮箱/手机号 |
| password | ceshi123 | string | 是 | 密码 |
| captcha_code | - | string | 是 | 图形验证码内容 |
| captcha_key | - | string | 是 | 图形验证码KEY |
| email | 123132123@qq.com | string | 是 | 邮箱地址，type=2必填 |
| email_code | 279911 | string | 是 | 电邮验证码，type=2必填 |
| phone | - | string | 是 | 手机号，type=3必填 |
| area_code | +86 | string | 是 | 国家区号，type=3必填 |
| phone_code | - | string | 是 | 短信验证码，type=3必填 |

**认证方式**

> 继承父级

**响应示例**

* 成功(200)

```javascript
{
	"code": 200,
	"msg": "success",
	"data": {
		"access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE3Mzo2NTUzNS9hcGkvdXNlci9sb2dpbiIsImlhdCI6MTcyMjE1NTQ1NiwiZXhwIjoxNzI0NzQ3NDU2LCJuYmYiOjE3MjIxNTU0NTYsImp0aSI6IjFzZXdVd1Y0anExdFlTVHciLCJzdWIiOiI2NTYiLCJwcnYiOiI4NjY1YWU5Nzc1Y2YyNmY2YjhlNDk2Zjg2ZmE1MzZkNjhkZDcxODE4In0.ph2Bed7OcfYODDSQtq26hiHqKj8nNMAft6YC-sjtJto",
		"token_type": "bearer",
		"expires_in": 2592000
	}
}
```

* 失败(404)

```javascript
{
	"code": 0,
	"msg": "账号密码错误"
}
```

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| lang | CN | string | 是 | - |

**Query**

#### 会员注册

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-04-13 11:11:31

> 更新时间: 2026-01-19 22:32:15

```text
暂无描述
```

**接口状态**

> 已完成

**接口URL**

> http://45.200.16.18:60000/api/user/register

**请求方式**

> POST

**Content-Type**

> json

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| lang | CN | string | 是 | - |

**请求Body参数**

```javascript
{
    "username": "ceshi7788",
    "password": "123456",
    "o_password": "123456",
    "currency": "CNY",
    "phone": "13145678949",
    "area_code": "",
    "phone_code": "",
    "qq": 123123123,
    "telegram": "321321",
    "email": "5454353",
    "name": "gfdg",
    "captcha_code": "1234",
    "captcha_key": "",
    "email_code": "123456",
    "invicode": "",
    "pay_password": "123456"
}
```

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| username | dd4646ss | string | 是 | 账号 |
| password | 123456 | string | 是 | 密码 |
| o_password | 123456 | string | 是 | 确认密码 |
| currency | CNY | string | 是 | 货币代码 |
| phone | 13145678949 | string | 否 | 手机号 |
| qq | 123123123 | number | 否 | QQ |
| telegram | 321321 | string | 否 | 飞机号 |
| email | 5454353 | string | 否 | 邮箱 |
| name | gfdg | string | 否 | 真实姓名 |
| captcha_code | - | string | 否 | 验证码 |
| captcha_key | - | string | 否 | 图片key，提交的时候需要有该参数 |
| email_code | - | string | 否 | 电邮验证码 |
| invicode | - | number | 否 | 推荐码，代理ID |
| pay_password | 123456 | string | 否 | 安全码，6-20位 |
| area_code | +86 | string | 否 | 国家区号 |
| phone_code | 123456 | string | 否 | 短信验证码 |

**认证方式**

> 继承父级

**响应示例**

* 成功(200)

```javascript
{
	"code": 200,
	"msg": "注册成功",
	"data": {
		"access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjY1NTM1L2FwaS91c2VyL3JlZ2lzdGVyIiwiaWF0IjoxNzI3Nzg3MzY2LCJleHAiOjE3MzAzNzkzNjYsIm5iZiI6MTcyNzc4NzM2NiwianRpIjoiRDFtaldiRTRBcENORlFpYiIsInN1YiI6IjY3MCIsInBydiI6Ijg2NjVhZTk3NzVjZjI2ZjZiOGU0OTZmODZmYTUzNmQ2OGRkNzE4MTgifQ.64fmqzZjbfjrR4sJH06SBWPPjC_8A_2a_eO4ghzPBbU",
		"token_type": "bearer",
		"expires_in": 2592000
	}
}
```

* 失败(200)

```javascript
{
	"code": 0,
	"msg": "用户已存在"
}
```

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| lang | CN | string | 是 | - |

**Query**

#### 获取个人信息

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-04-13 11:11:31

> 更新时间: 2026-03-23 10:59:11

```text
暂无描述
```

**接口状态**

> 已完成

**接口URL**

> http://45.200.16.18:60000/api/token/user

**请求方式**

> POST

**Content-Type**

> json

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjYwMDAwL2FwaS91c2VyL2xvZ2luIiwiaWF0IjoxNzcxNjgyODEzLCJleHAiOjE3NzQyNzQ4MTMsIm5iZiI6MTc3MTY4MjgxMywianRpIjoiaWhEbjlwWDFEdHF6aDF6ciIsInN1YiI6IjY2MiIsInBydiI6Ijg2NjVhZTk3NzVjZjI2ZjZiOGU0OTZmODZmYTUzNmQ2OGRkNzE4MTgifQ.Ae-zqOmpmBdegteNl5lssxB9iZCzdtQ6c-hJixevIoo | string | 是 | - |
| lang | CN | string | 是 | - |

**请求Body参数**

```javascript
暂无数据
```

**认证方式**

> 继承父级

**响应示例**

* 成功(200)

```javascript
{
	"code": 200,
	"msg": "success",
	"data": [
		{
			"id": 662,
			"username": "ceshi123",
			"real_name": "测试",
			"balance": "1835.0000",
			"lock_balance": "0.0000",
			"vip_level": "VIP3",
			"phone": "131456789490",
			"currency": "CNY",
			"status": 1,
			"fs_status": 1,
			"is_agent": 1,
			"telegram": null,
			"qq": "",
			"weixin": null,
			"skype": null,
			"email": "123456@qq.com",
			"transfer": 2,
			"img": "",
			"gender": "",
			"born_time": "2004-02-20",
			"symbol": "￥",
			"level_data": {
				"recharge": 0,
				"validBetAmount": 0,
				"next_recharge": "500.00",
				"next_validBetAmount": "233.00",
				"gap_recharge": 500,
				"gap_validBetAmount": 233,
				"vip_level": "VIP3",
				"next_vip_level": "VIP4"
			},
			"pay_password": true,
			"sum_water": "0.0000",
			"ok_water": "0.0000"
		}
	]
}
```

| 参数名 | 示例值 | 参数类型 | 参数描述 |
| --- | --- | ---- | ---- |
| code | 200 | number | - |
| msg | success | string | - |
| data | - | array | - |
| data.id | 662 | number | 账号ID |
| data.username | ceshi123 | string | 账号 |
| data.real_name | 测试 | string | 真实姓名 |
| data.balance | 1835.0000 | string | 钱包余额 |
| data.lock_balance | 0.0000 | string | 锁定钱包余额 |
| data.vip_level | VIP3 | string | 会员等级 |
| data.phone | 131456789490 | string | 手机号 |
| data.currency | CNY | string | 货币代码 |
| data.status | 1 | number | 会员状态：1正常，0禁用 |
| data.fs_status | 1 | number | 反佣状态：1正常，0禁用 |
| data.is_agent | 1 | number | 是否代理：1是，0不是 |
| data.telegram | - | null | - |
| data.qq | - | string | - |
| data.weixin | - | null | - |
| data.skype | - | null | - |
| data.email | 123456@qq.com | string | - |
| data.transfer | 2 | number | 转账模式：1手动，2免转 |
| data.img | - | string | 头像 |
| data.gender | - | string | 性别 |
| data.born_time | 2004-02-20 | string | 出生日期 |
| data.symbol | ￥ | string | 金融符号 |
| data.level_data | - | object | 等级数据 |
| data.level_data.recharge | 0 | number | 当前总充值 |
| data.level_data.validBetAmount | 0 | number | 当前总投注 |
| data.level_data.next_recharge | 500.00 | string | 下一级需要的充值 |
| data.level_data.next_validBetAmount | 233.00 | string | 下一级需要的投注 |
| data.level_data.gap_recharge | 500 | number | 晋级还需充值 |
| data.level_data.gap_validBetAmount | 233 | number | 晋级还需投注 |
| data.level_data.vip_level | VIP3 | string | 当前等级 |
| data.level_data.next_vip_level | VIP4 | string | 下一级等级 |
| data.pay_password | true | boolean | 是否绑定安全码：true是，false否 |
| data.sum_water | 0.0000 | string | 需要完成的流水 |
| data.ok_water | 0.0000 | string | 已完成的流水 |

* 失败(200)

```javascript
{
	"code": 401,
	"msg": "认证失败！"
}
```

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjYwMDAwL2FwaS91c2VyL2xvZ2luIiwiaWF0IjoxNzcxNjgyODEzLCJleHAiOjE3NzQyNzQ4MTMsIm5iZiI6MTc3MTY4MjgxMywianRpIjoiaWhEbjlwWDFEdHF6aDF6ciIsInN1YiI6IjY2MiIsInBydiI6Ijg2NjVhZTk3NzVjZjI2ZjZiOGU0OTZmODZmYTUzNmQ2OGRkNzE4MTgifQ.Ae-zqOmpmBdegteNl5lssxB9iZCzdtQ6c-hJixevIoo | string | 是 | - |
| lang | CN | string | 是 | - |

**Query**

#### 退出登录

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-04-13 11:11:31

> 更新时间: 2025-04-18 17:14:04

```text
暂无描述
```

**接口状态**

> 已完成

**接口URL**

> http://45.200.16.18:60000/api/token/logout

**请求方式**

> POST

**Content-Type**

> json

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE3Mzo2NTUzNS9hcGkvdXNlci9sb2dpbiIsImlhdCI6MTcyMjE1NTQ1NiwiZXhwIjoxNzI0NzQ3NDU2LCJuYmYiOjE3MjIxNTU0NTYsImp0aSI6IjFzZXdVd1Y0anExdFlTVHciLCJzdWIiOiI2NTYiLCJwcnYiOiI4NjY1YWU5Nzc1Y2YyNmY2YjhlNDk2Zjg2ZmE1MzZkNjhkZDcxODE4In0.ph2Bed7OcfYODDSQtq26hiHqKj8nNMAft6YC-sjtJto | string | 是 | - |
| lang | CN | string | 是 | - |

**请求Body参数**

```javascript
暂无数据
```

**认证方式**

> 继承父级

**响应示例**

* 成功(200)

```javascript
{
	"code": 200,
	"msg": "退出成功",
	"data": []
}
```

* 失败(404)

```javascript
{
	"code": 401,
	"msg": "认证失败！"
}
```

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE3Mzo2NTUzNS9hcGkvdXNlci9sb2dpbiIsImlhdCI6MTcyMjE1NTQ1NiwiZXhwIjoxNzI0NzQ3NDU2LCJuYmYiOjE3MjIxNTU0NTYsImp0aSI6IjFzZXdVd1Y0anExdFlTVHciLCJzdWIiOiI2NTYiLCJwcnYiOiI4NjY1YWU5Nzc1Y2YyNmY2YjhlNDk2Zjg2ZmE1MzZkNjhkZDcxODE4In0.ph2Bed7OcfYODDSQtq26hiHqKj8nNMAft6YC-sjtJto | string | 是 | - |
| lang | CN | string | 是 | - |

**Query**

#### 获取图形验证码

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-04-13 11:11:31

> 更新时间: 2025-04-21 20:29:45

```text
暂无描述
```

**接口状态**

> 已完成

**接口URL**

> http://45.200.16.18:60000/api/captcha/get

**请求方式**

> POST

**Content-Type**

> json

**请求Body参数**

```javascript
暂无数据
```

**认证方式**

> 继承父级

**响应示例**

* 成功(200)

```javascript
{
	"code": 200,
	"msg": "注册成功",
	"data": {
		"captcha_key": "$2y$10$VfFq9taEU3K04Djl5i67zuLCjd8jHWisZLGmQfY1JCDVLAfOOWdja",
		"captcha_img": "data:image/jpeg;base64,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"
	}
}
```

| 参数名 | 示例值 | 参数类型 | 参数描述 |
| --- | --- | ---- | ---- |
| code | 200 | number | - |
| msg | 注册成功 | string | - |
| data | - | object | - |
| data.captcha_key | $2y$10$VfFq9taEU3K04Djl5i67zuLCjd8jHWisZLGmQfY1JCDVLAfOOWdja | string | 图片key，提交的时候需要有该参数 |
| data.captcha_code | data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEASABIAAD//gA7Q1JFQVRPUjogZ2QtanBlZyB2MS4wICh1c2luZyBJSkcgSlBFRyB2ODApLCBxdWFsaXR5ID0gNzUK/9sAQwAIBgYHBgUIBwcHCQkICgwUDQwLCwwZEhMPFB0aHx4dGhwcICQuJyAiLCMcHCg3KSwwMTQ0NB8nOT04MjwuMzQy/9sAQwEJCQkMCwwYDQ0YMiEcITIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIy/8AAEQgAJAB4AwEiAAIRAQMRAf/EAB8AAAEFAQEBAQEBAAAAAAAAAAABAgMEBQYHCAkKC//EALUQAAIBAwMCBAMFBQQEAAABfQECAwAEEQUSITFBBhNRYQcicRQygZGhCCNCscEVUtHwJDNicoIJChYXGBkaJSYnKCkqNDU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6g4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2drh4uPk5ebn6Onq8fLz9PX29/j5+v/EAB8BAAMBAQEBAQEBAQEAAAAAAAABAgMEBQYHCAkKC//EALURAAIBAgQEAwQHBQQEAAECdwABAgMRBAUhMQYSQVEHYXETIjKBCBRCkaGxwQkjM1LwFWJy0QoWJDThJfEXGBkaJicoKSo1Njc4OTpDREVGR0hJSlNUVVZXWFlaY2RlZmdoaWpzdHV2d3h5eoKDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uLj5OXm5+jp6vLz9PX29/j5+v/aAAwDAQACEQMRAD8A9cAVui1KiEkYSpDPbQIXd1VVGSzHAFQprFjMjNb3UEoX7xSQNj64pqLaukOzLqqFHSoLifYOKrNdPJ93oaRYZZDk0hEX2mNrpIWlQTMNyoTyR64q55rrwBXN6rNFpnirS7m4JEfkyg4GSeOAB3JJFXW8Tx20kbXul3trA7BRNKgwM/3hnis/aK7THY3IzITzU2Kj8+MDrUUl0APlrQQ+Ztq8VRZixyaT7R543I4ZT3U5FAFACgU9YSe1Ea5NS3N1DYWpnmJ2jjA6k+gppNuyGk27IZLPDYQGa4bZGDgn0qJJPt8qzSqVtkIaGIjG8jo7D9QO3U84242q3c+pac0strNBZ8NETg+Y2eC3oPT16+ldKkayRq/94A1vKHsop9fy/wCCdMoexgn9p3+X/B/IesoY4FFCxqpornOU4jW4JNR17TtHkZhBIDNKAcbgM4H6H86b4s0PT9P0Jri3hWCYMqAx8bgTyD68Vv6/o15Pe2eq6WY/ttrkbJOFkU9Rn8T+dc94ll1e9XT7a/sIbSOa6RQomEjOenbgDmvbwknKVH2crJbq9tbtvTrdHbSbbhyvRbnWWCw21lbxd441X8hitCORXHy1nXK+SrPHG8xHSNCoJ/76IH61SNuZ5DKujTJM3WVblYmPbko2TXlRh7RuUnb7v1aMKdP2msnb7v1aG6/Gp8T+HmYAjzJfzwpH607xem/w7eDHRQfyYGqd5o+u3N1Z3ELxqbVy6Ldz7xz/ALqA/mTU+qW+v3mny201pZSCRdrG3lO78AwA/WpeEfvJSWvn5Gzwu1px+9F2wDTWVuw53Rqf0qzexC30u7mbqkLt+Sk1jWV1fWVvFBNNFZiNAm64spGGAMcsH2/rTtalu5vDV/PHq1rcReSQRbwjBB4xnca1jhZXSb/P/KxMsHO1uZK/rb77WH+CbZB4ZhkI/wBY7tn8cf0qHxjNJAmnQ20zxPNcAExsVJHTt9ad4XtJpvDVoYNWnjQKQUiSP5Tk5HzKTWJrkZm8TadYtfXE7RvuYsy5TJB42gYOB/Kq5Ie0b5u/f/I82pTpQwyjGorOyW/+SOyEioayNWme8e3eWLbZQXC7w4/1mDgkj+6Onv8ATGZRpULfenvG/wC3px/IinjRrF/lkjlkB6h53b+ZqacqdOV7v7v+CenSlSpy5ru/p/wTQ1Qp/Y9yZCNpjOPc9v1p1jdwDTLVpJo1PlLncwHaqsHhfRo23/2fE59JMuPyNW4dH02BQsWn2ygdMRL/AIUm6PLypv7l/mS3QUeVNv5JfqxJdX0yP7+o2i/706j+tFWkgij+5Ei/7qgUVF6XZ/f/AMAi9Hs/vX+RIWOK47xTIz+IdARj8omZvxG3FFFb4H+N8pf+ksKHx/f+RsqSW5NX7cUUVxmJYpRyaKKAHgVnX+iafqK/6RbR79ykyKoD8EHG7GcHGD7UUVpSlKM04uxrRnKFROLsc9qfhKx0+2mubG4vbY4/1cc3y/qCf1rD0iGJr/R5xGqu4m3kZ+YguMnPOeKKK9Crrh1J7v8AyYsdRprDU6nKubmjrbXfud5CoxVmNFJ6UUV5ZmT0UUUAJRRRQB//2Q== | string | 图片base64 |

* 失败(404)

```javascript
{
	"code": 401,
	"msg": "认证失败！"
}
```

**Query**

#### 获取电邮验证码

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-04-20 10:14:42

> 更新时间: 2026-01-18 16:14:27

```text
暂无描述
```

**接口状态**

> 已完成

**接口URL**

> http://45.200.16.18:60000/api/mail_code/send

**请求方式**

> POST

**Content-Type**

> json

**请求Body参数**

```javascript
{
    "type": 2,
    "email": "123456@qq.com"
}
```

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| type | 2 | number | 是 | 验证类型：1会员登陆，2会员注册 |
| email | 123456@qq.com | string | 是 | 邮箱地址 |

**认证方式**

> 继承父级

**响应示例**

* 成功(200)

```javascript
{
	"code": 200,
	"msg": "注册成功",
	"data": {
		"captcha_key": "$2y$10$VfFq9taEU3K04Djl5i67zuLCjd8jHWisZLGmQfY1JCDVLAfOOWdja",
		"captcha_img": "data:image/jpeg;base64,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"
	}
}
```

| 参数名 | 示例值 | 参数类型 | 参数描述 |
| --- | --- | ---- | ---- |
| code | 200 | number | - |
| msg | 注册成功 | string | - |
| data | - | object | - |
| data.captcha_key | $2y$10$VfFq9taEU3K04Djl5i67zuLCjd8jHWisZLGmQfY1JCDVLAfOOWdja | string | 图片key，提交的时候需要有该参数 |
| data.captcha_code | data:image/jpeg;base64,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 | string | 图片base64 |

* 失败(404)

```javascript
{
	"code": 401,
	"msg": "认证失败！"
}
```

**Query**

#### 设置安全码

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-12-11 16:05:28

> 更新时间: 2025-12-11 16:06:27

```text
暂无描述
```

**接口状态**

> 已完成

**接口URL**

> http://45.200.16.18:60000/api/user/pay_password

**请求方式**

> POST

**Content-Type**

> json

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjYwMDAwL2FwaS91c2VyL3JlZ2lzdGVyIiwiaWF0IjoxNzY1NDM3MDU4LCJleHAiOjE3NjgwMjkwNTgsIm5iZiI6MTc2NTQzNzA1OCwianRpIjoibkFqVVZUVUhWaFVHT3R1MCIsInN1YiI6Ijc0MSIsInBydiI6Ijg2NjVhZTk3NzVjZjI2ZjZiOGU0OTZmODZmYTUzNmQ2OGRkNzE4MTgifQ.kvxspraCKt1FlqsibeJA04Oz8MLTfbmhLqalVNKOQkw | string | 是 | - |
| lang | CN | string | 是 | - |

**请求Body参数**

```javascript
{
    "pay_password": "123456"
}
```

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| pay_password | 123456 | string | 是 | 安全码，6-20位 |

**认证方式**

> 继承父级

**响应示例**

* 成功(200)

```javascript
{
	"code": 200,
	"msg": "success",
	"data": [
		{
			"id": 662,
			"username": "ceshi123",
			"real_name": "测试",
			"balance": "1835.0000",
			"lock_balance": "0.0000",
			"vip_level": "VIP3",
			"phone": "131456789490",
			"currency": "CNY",
			"status": 1,
			"fs_status": 1,
			"is_agent": 1,
			"telegram": null,
			"qq": "",
			"weixin": null,
			"skype": null,
			"email": "123456@qq.com",
			"transfer": 2,
			"img": "",
			"gender": "",
			"born_time": "2004-02-20",
			"symbol": "￥",
			"level_data": {
				"recharge": 0,
				"validBetAmount": 0,
				"next_recharge": "500.00",
				"next_validBetAmount": "233.00",
				"gap_recharge": 500,
				"gap_validBetAmount": 233,
				"vip_level": "VIP3",
				"next_vip_level": "VIP4"
			},
			"pay_password": true
		}
	]
}
```

| 参数名 | 示例值 | 参数类型 | 参数描述 |
| --- | --- | ---- | ---- |
| code | 200 | number | - |
| msg | success | string | - |
| data | - | array | - |
| data.id | 662 | number | 账号ID |
| data.username | ceshi123 | string | 账号 |
| data.real_name | 测试 | string | 真实姓名 |
| data.balance | 1835.0000 | string | 钱包余额 |
| data.lock_balance | 0.0000 | string | 锁定钱包余额 |
| data.vip_level | VIP3 | string | 会员等级 |
| data.phone | 131456789490 | string | 手机号 |
| data.currency | CNY | string | 货币代码 |
| data.status | 1 | number | 会员状态：1正常，0禁用 |
| data.fs_status | 1 | number | 反佣状态：1正常，0禁用 |
| data.is_agent | 1 | number | 是否代理：1是，0不是 |
| data.telegram | - | null | - |
| data.qq | - | string | - |
| data.weixin | - | null | - |
| data.skype | - | null | - |
| data.email | 123456@qq.com | string | - |
| data.transfer | 2 | number | 转账模式：1手动，2免转 |
| data.img | - | string | 头像 |
| data.gender | - | string | 性别 |
| data.born_time | 2004-02-20 | string | 出生日期 |
| data.symbol | ￥ | string | 金融符号 |
| data.level_data | - | object | 等级数据 |
| data.level_data.recharge | 0 | number | 当前总充值 |
| data.level_data.validBetAmount | 0 | number | 当前总投注 |
| data.level_data.next_recharge | 500.00 | string | 下一级需要的充值 |
| data.level_data.next_validBetAmount | 233.00 | string | 下一级需要的投注 |
| data.level_data.gap_recharge | 500 | number | 晋级还需充值 |
| data.level_data.gap_validBetAmount | 233 | number | 晋级还需投注 |
| data.level_data.vip_level | VIP3 | string | 当前等级 |
| data.level_data.next_vip_level | VIP4 | string | 下一级等级 |
| pay_password | true | boolean | 是否绑定安全码：true是，false否 |

* 失败(200)

```javascript
{
	"code": 401,
	"msg": "认证失败！"
}
```

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjYwMDAwL2FwaS91c2VyL3JlZ2lzdGVyIiwiaWF0IjoxNzY1NDM3MDU4LCJleHAiOjE3NjgwMjkwNTgsIm5iZiI6MTc2NTQzNzA1OCwianRpIjoibkFqVVZUVUhWaFVHT3R1MCIsInN1YiI6Ijc0MSIsInBydiI6Ijg2NjVhZTk3NzVjZjI2ZjZiOGU0OTZmODZmYTUzNmQ2OGRkNzE4MTgifQ.kvxspraCKt1FlqsibeJA04Oz8MLTfbmhLqalVNKOQkw | string | 是 | - |
| lang | CN | string | 是 | - |

**Query**

#### 获取短信验证码

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2026-01-18 12:24:23

> 更新时间: 2026-01-18 16:48:31

```text
暂无描述
```

**接口状态**

> 已完成

**接口URL**

> http://45.200.16.18:60000/api/phone_code/send

**请求方式**

> POST

**Content-Type**

> json

**请求Body参数**

```javascript
{
    "type": 2,
    "area_code": "+86",
    "phone": "13145678946"
}
```

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| type | 2 | number | 是 | 验证类型：1会员登陆，2会员注册，3代理登陆，4后台登陆 |
| area_code | +86 | string | 是 | 国家区号 |
| phone | 13145678946 | string | 是 | 手机号 |

**认证方式**

> 继承父级

**响应示例**

* 成功(200)

```javascript
{
	"code": 200,
	"msg": "注册成功",
	"data": {
		"captcha_key": "$2y$10$VfFq9taEU3K04Djl5i67zuLCjd8jHWisZLGmQfY1JCDVLAfOOWdja",
		"captcha_img": "data:image/jpeg;base64,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"
	}
}
```

| 参数名 | 示例值 | 参数类型 | 参数描述 |
| --- | --- | ---- | ---- |
| code | 200 | number | - |
| msg | 注册成功 | string | - |
| data | - | object | - |
| data.captcha_key | $2y$10$VfFq9taEU3K04Djl5i67zuLCjd8jHWisZLGmQfY1JCDVLAfOOWdja | string | 图片key，提交的时候需要有该参数 |
| data.captcha_code | data:image/jpeg;base64,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 | string | 图片base64 |

* 失败(404)

```javascript
{
	"code": 401,
	"msg": "认证失败！"
}
```

**Query**

#### 获取找回密码验证码

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2026-02-06 14:41:28

> 更新时间: 2026-02-06 15:48:08

```text
暂无描述
```

**接口状态**

> 已完成

**接口URL**

> http://45.200.16.18:60000/api/code/send

**请求方式**

> POST

**Content-Type**

> json

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| lang | CN | string | 是 | - |

**请求Body参数**

```javascript
{
    "type": 1,
    "area_code": "+86",
    "phone": "13145678913",
    "email": "123132111123@qq.com"
}
```

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| type | 1 | number | 是 | 类型：1手机验证码，2邮箱验证码 |
| area_code | +86 | string | 否 | 国家区号，type=1必填 |
| phone | 13145678913 | string | 否 | 手机号，type=1必填 |
| email | 123132123@qq.com | string | 否 | 邮箱地址，type=2必填 |

**认证方式**

> 继承父级

**响应示例**

* 成功(200)

```javascript
{
	"code": 200,
	"msg": "验证码发送成功"
}
```

* 失败(404)

```javascript
{
	"code": 0,
	"msg": "该手机号暂未绑定会员"
}
```

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| lang | CN | string | 是 | - |

**Query**

#### 确认找回密码

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2026-02-06 15:48:20

> 更新时间: 2026-02-06 16:37:40

```text
暂无描述
```

**接口状态**

> 已完成

**接口URL**

> http://45.200.16.18:60000/api/password/get

**请求方式**

> POST

**Content-Type**

> json

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| lang | CN | string | 是 | - |

**请求Body参数**

```javascript
{
    "type": 1,
    "area_code": "+86",
    "phone": "13145678913",
    "email": "123132111123@qq.com",
    "real_name": "张三",
    "pay_password": "123456",
    "code": 123456,
    "password": "123456"
}
```

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| type | 1 | number | 是 | 类型：1手机号验证码找回，2邮箱验证码找回，3真实姓名+安全密码找回 |
| area_code | +86 | string | 否 | 国家区号，type=1必填 |
| phone | 13145678913 | string | 否 | 手机号，type=1必填 |
| email | 123132111123@qq.com | string | 否 | 邮箱地址，type=2必填 |
| real_name | 张三 | string | 否 | 真实姓名，type=3必填 |
| pay_password | 123456 | string | 否 | 安全密码，type=3必填 |
| code | 123456 | string | 否 | 手机或邮件验证码，type=1，type=2必填 |
| password | 123456 | string | 是 | 需要修改的新密码 |

**认证方式**

> 继承父级

**响应示例**

* 成功(200)

```javascript
{
	"code": 200,
	"msg": "密码修改成功"
}
```

* 失败(404)

```javascript
{
	"code": 0,
	"msg": "该手机号暂未绑定会员"
}
```

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| lang | CN | string | 是 | - |

**Query**

#### telegram登陆

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2026-02-20 11:20:16

> 更新时间: 2026-02-21 22:27:40

```text
暂无描述
```

**接口状态**

> 已完成

**接口URL**

> http://45.200.16.18:60000/api/telegram/login

**请求方式**

> POST

**Content-Type**

> json

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| lang | CN | string | 是 | - |

**请求Body参数**

```javascript
{
    "user_id": 6782975779,
    "username": "tommy7780"
}
```

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| user_id | 1 | number | 是 | - |
| username | ceshi123 | string | 是 | - |

**认证方式**

> 继承父级

**响应示例**

* 成功(200)

```javascript
{
	"code": 200,
	"msg": "telegram验证成功",
	"data": {
		"one_login": true,
		"access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE3Mzo2NTUzNS9hcGkvdXNlci9sb2dpbiIsImlhdCI6MTcyMjE1NTQ1NiwiZXhwIjoxNzI0NzQ3NDU2LCJuYmYiOjE3MjIxNTU0NTYsImp0aSI6IjFzZXdVd1Y0anExdFlTVHciLCJzdWIiOiI2NTYiLCJwcnYiOiI4NjY1YWU5Nzc1Y2YyNmY2YjhlNDk2Zjg2ZmE1MzZkNjhkZDcxODE4In0.ph2Bed7OcfYODDSQtq26hiHqKj8nNMAft6YC-sjtJto",
		"token_type": "bearer",
		"expires_in": 2592000
	}
}
```

| 参数名 | 示例值 | 参数类型 | 参数描述 |
| --- | --- | ---- | ---- |
| code | 200 | number | - |
| msg | telegram验证成功 | string | - |
| data | - | object | - |
| data.one_login | true | boolean | 判断是否首次登陆：true则需要强制设置密码，false则跳过 |
| data.access_token | eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE3Mzo2NTUzNS9hcGkvdXNlci9sb2dpbiIsImlhdCI6MTcyMjE1NTQ1NiwiZXhwIjoxNzI0NzQ3NDU2LCJuYmYiOjE3MjIxNTU0NTYsImp0aSI6IjFzZXdVd1Y0anExdFlTVHciLCJzdWIiOiI2NTYiLCJwcnYiOiI4NjY1YWU5Nzc1Y2YyNmY2YjhlNDk2Zjg2ZmE1MzZkNjhkZDcxODE4In0.ph2Bed7OcfYODDSQtq26hiHqKj8nNMAft6YC-sjtJto | string | - |
| data.token_type | bearer | string | - |
| data.expires_in | 2592000 | number | - |

* 失败(404)

```javascript
{
	"code": 0,
	"msg": "用户信息异常，认证失败"
}
```

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| lang | CN | string | 是 | - |

**Query**

#### telegram用户设置密码

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2026-02-21 22:32:27

> 更新时间: 2026-02-21 22:44:40

```text
暂无描述
```

**接口状态**

> 已完成

**接口URL**

> http://45.200.16.18:60000/api/telegram/password

**请求方式**

> POST

**Content-Type**

> json

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| lang | CN | string | 是 | - |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjYwMDAwL2FwaS90ZWxlZ3JhbS9sb2dpbiIsImlhdCI6MTc3MTY4NDcwNiwiZXhwIjoxNzc0Mjc2NzA2LCJuYmYiOjE3NzE2ODQ3MDYsImp0aSI6IkljNjlzZEhMSlJ6QzRqbzUiLCJzdWIiOiI3ODMiLCJwcnYiOiI4NjY1YWU5Nzc1Y2YyNmY2YjhlNDk2Zjg2ZmE1MzZkNjhkZDcxODE4In0.hZ5HbhLRNYYoYGOIqSWQGo3Ei5cEY5DLVfk2UM-HTS8 | string | 是 | - |

**请求Body参数**

```javascript
{
    "newPass": 123456,
    "confirmpass": 123456
}
```

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| newPass | 6782975779 | number | 是 | 新密码 |
| confirmpass | tommy7780 | string | 是 | 确认新密码 |

**认证方式**

> 继承父级

**响应示例**

* 成功(200)

```javascript
{
	"code": 200,
	"msg": "设置密码成功",
	"data": []
}
```

| 参数名 | 示例值 | 参数类型 | 参数描述 |
| --- | --- | ---- | ---- |
| code | 200 | number | - |
| msg | 设置密码成功 | string | - |
| data | - | array | - |

* 失败(404)

```javascript
{
	"code": 0,
	"msg": "用户信息异常，认证失败"
}
```

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| lang | CN | string | 是 | - |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjYwMDAwL2FwaS90ZWxlZ3JhbS9sb2dpbiIsImlhdCI6MTc3MTY4NDcwNiwiZXhwIjoxNzc0Mjc2NzA2LCJuYmYiOjE3NzE2ODQ3MDYsImp0aSI6IkljNjlzZEhMSlJ6QzRqbzUiLCJzdWIiOiI3ODMiLCJwcnYiOiI4NjY1YWU5Nzc1Y2YyNmY2YjhlNDk2Zjg2ZmE1MzZkNjhkZDcxODE4In0.hZ5HbhLRNYYoYGOIqSWQGo3Ei5cEY5DLVfk2UM-HTS8 | string | 是 | - |

**Query**

### 首页数据

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-04-13 11:11:31

> 更新时间: 2025-04-13 11:11:31

```text
暂无描述
```

**目录Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| 暂无参数 |

**目录Query参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| 暂无参数 |

**目录Body参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| 暂无参数 |

**目录认证信息**

> 继承父级

**Query**

#### 获取Category分类

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-04-13 11:11:31

> 更新时间: 2026-03-26 23:01:51

```text
暂无描述
```

**接口状态**

> 已完成

**接口URL**

> http://45.200.16.18:60000/api/interface/class

**请求方式**

> POST

**Content-Type**

> json

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| lang | CN | string | 是 | - |

**请求Body参数**

```javascript
暂无数据
```

**认证方式**

> 继承父级

**响应示例**

* 成功(200)

```javascript
{
	"code": 200,
	"msg": "success",
	"data": [
		{
			"id": 46,
			"title": "推荐",
			"code": "reco",
			"img": "",
			"se_img": "",
			"banner": null
		},
		{
			"id": 39,
			"title": "视讯",
			"code": "live",
			"img": "https://apis.xh-demo.com/uploads/images/jkfl/live.png",
			"se_img": "https://apis.xh-demo.com/uploads/images/jkfl/live_se.png",
			"banner": null
		},
		{
			"id": 40,
			"title": "电子",
			"code": "game",
			"img": "https://apis.xh-demo.com/uploads/images/jkfl/game.png",
			"se_img": "https://apis.xh-demo.com/uploads/images/jkfl/game_se.png",
			"banner": null
		},
		{
			"id": 41,
			"title": "捕鱼",
			"code": "fishing",
			"img": "https://apis.xh-demo.com/uploads/images/jkfl/fishing.png",
			"se_img": "https://apis.xh-demo.com/uploads/images/jkfl/fishing_se.png",
			"banner": null
		},
		{
			"id": 42,
			"title": "彩票",
			"code": "lottery",
			"img": "https://apis.xh-demo.com/uploads/images/jkfl/lottery.png",
			"se_img": "https://apis.xh-demo.com/uploads/images/jkfl/lottery_se.png",
			"banner": null
		},
		{
			"id": 43,
			"title": "体育",
			"code": "sport",
			"img": "https://apis.xh-demo.com/uploads/images/jkfl/sport.png",
			"se_img": "https://apis.xh-demo.com/uploads/images/jkfl/sport_se.png",
			"banner": null
		},
		{
			"id": 44,
			"title": "棋牌",
			"code": "poker",
			"img": "https://apis.xh-demo.com/uploads/images/jkfl/poker.png",
			"se_img": "https://apis.xh-demo.com/uploads/images/jkfl/poker_se.png",
			"banner": null
		},
		{
			"id": 45,
			"title": "电竞",
			"code": "esports",
			"img": "https://apis.xh-demo.com/uploads/images/jkfl/esports.png",
			"se_img": "https://apis.xh-demo.com/uploads/images/jkfl/esports_se.png",
			"banner": null
		}
	]
}
```

| 参数名 | 示例值 | 参数类型 | 参数描述 |
| --- | --- | ---- | ---- |
| code | 200 | number | - |
| msg | success | string | - |
| data | - | array | - |
| data.id | 39 | number | 数据ID |
| data.title | 视讯 | string | 分类名称 |
| data.code | live | string | 分类标识 |
| data.img | - | string | 未选中图片 |
| data.se_img | - | string | 选中图片 |
| data.banner | - | string | 背景大图 |

* 失败(200)

```javascript
暂无数据
```

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| lang | CN | string | 是 | - |

**Query**

#### Category二级分类

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-04-13 11:11:31

> 更新时间: 2026-04-17 00:45:29

```text
暂无描述
```

**接口状态**

> 已完成

**接口URL**

> http://45.200.16.18:60000/api/interface/list

**请求方式**

> POST

**Content-Type**

> json

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| lang | CN | string | 是 | - |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjYwMDAwL2FwaS91c2VyL2xvZ2luIiwiaWF0IjoxNzUzNzU2NTQxLCJleHAiOjE3NTYzNDg1NDEsIm5iZiI6MTc1Mzc1NjU0MSwianRpIjoiVDRGVnFpSTc0dWhHNGQ2byIsInN1YiI6IjY2MiIsInBydiI6Ijg2NjVhZTk3NzVjZjI2ZjZiOGU0OTZmODZmYTUzNmQ2OGRkNzE4MTgifQ.IS_uy8Kgqv63i5amzxOkTa1Ifh0ltev4yA5N6fYjsKc | string | 是 | - |

**请求Body参数**

```javascript
{
    "code": "live"
}
```

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| code | live | string | 否 | 分类标识，不传则返回全部 |

**认证方式**

> 继承父级

**响应示例**

* 成功(200)

```javascript
{
	"code": 200,
	"msg": "success",
	"data": [
		{
			"id": 1,
			"code": "AG",
			"title": "PA视讯",
			"label": "[\"hot\",\"reco\"]",
			"img": "https://229382.xh-bw.com/uploads/images/apipicture/pc/AG.png",
			"type": "live",
			"status_s": 1,
			"pc_logo": "https://229382.xh-bw.com/uploads/images/apipicture/pc/logo/AGLOGO.png",
			"pc_drop": "https://229382.xh-bw.com/uploads/images/apipicture/pc/AG.png",
			"h5_logo": "https://229382.xh-bw.com/uploads/images/apipicture/m1/AG.png",
			"category": 0,
			"favorites": false,
			"nesting": 1
		}
	]
}
```

| 参数名 | 示例值 | 参数类型 | 参数描述 |
| --- | --- | ---- | ---- |
| code | 200 | number | - |
| msg | success | string | - |
| data | - | array | - |
| data.id | 1 | number | 数据ID |
| data.code | AG | string | 分类标识 |
| data.title | PA视讯 | string | 分类名称 |
| data.label | ["hot","reco"] | string | 标签 |
| data.img | https://229382.xh-bw.com/uploads/images/apipicture/pc/AG.png | string | 图片 |
| data.type | live | string | 游戏类型 |
| data.status_s | 1 | number | 是否维护：1正常，0维护中 |
| data.pc_logo | https://229382.xh-bw.com/uploads/images/apipicture/pc/logo/AGLOGO.png | string | PC logo |
| data.pc_drop | https://229382.xh-bw.com/uploads/images/apipicture/pc/AG.png | string | PC 下拉 |
| data.h5_logo | https://229382.xh-bw.com/uploads/images/apipicture/m1/AG.png | string | H5 logo |
| data.category | 0 | number | 是否二级页面：1是，0否 |
| data.favorites | false | boolean | 是否收藏：true是，false否，此参数只针对登陆用户有效 |
| data.nesting | 1 | string | 是否支持嵌套：1是，0否 |

* 失败(200)

```javascript
暂无数据
```

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| lang | CN | string | 是 | - |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjYwMDAwL2FwaS91c2VyL2xvZ2luIiwiaWF0IjoxNzUzNzU2NTQxLCJleHAiOjE3NTYzNDg1NDEsIm5iZiI6MTc1Mzc1NjU0MSwianRpIjoiVDRGVnFpSTc0dWhHNGQ2byIsInN1YiI6IjY2MiIsInBydiI6Ijg2NjVhZTk3NzVjZjI2ZjZiOGU0OTZmODZmYTUzNmQ2OGRkNzE4MTgifQ.IS_uy8Kgqv63i5amzxOkTa1Ifh0ltev4yA5N6fYjsKc | string | 是 | - |

**Query**

#### 获取子游戏列表

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-04-13 11:11:31

> 更新时间: 2026-03-28 21:45:19

```text
暂无描述
```

**接口状态**

> 已完成

**接口URL**

> http://45.200.16.18:60000/api/gamelist/getlist

**请求方式**

> POST

**Content-Type**

> json

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| lang | CN | string | 是 | - |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjYwMDAwL2FwaS91c2VyL2xvZ2luIiwiaWF0IjoxNzUzNzU2NTQxLCJleHAiOjE3NTYzNDg1NDEsIm5iZiI6MTc1Mzc1NjU0MSwianRpIjoiVDRGVnFpSTc0dWhHNGQ2byIsInN1YiI6IjY2MiIsInBydiI6Ijg2NjVhZTk3NzVjZjI2ZjZiOGU0OTZmODZmYTUzNmQ2OGRkNzE4MTgifQ.IS_uy8Kgqv63i5amzxOkTa1Ifh0ltev4yA5N6fYjsKc | string | 是 | - |

**请求Body参数**

```javascript
{
    "page": 1,
    "size": 10,
    "game": "CQ9",
    "code": "game",
    "search_word": "",
    "type": "",
    "label": ""
}
```

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| page | 1 | number | 是 | - |
| size | 10 | number | 是 | - |
| game | CQ9 | string | 否 | 接口标识 |
| code | game | string | 否 | 游戏类型 |
| search_word | - | string | 否 | 搜索参数，仅支持搜索游戏名字 |
| label | - | string | 否 | 热门  hot |
| type | game | string | 否 | 与code参数一样，选其一就行 |

**认证方式**

> 继承父级

**响应示例**

* 成功(200)

```javascript
{
	"code": 200,
	"msg": "success",
	"data": {
		"data": [
			{
				"id": 1,
				"title": "111",
				"img": ""
			}
		],
		"current_page": 1,
		"total": 1,
		"lastPage": 1
	}
}
```

| 参数名 | 示例值 | 参数类型 | 参数描述 |
| --- | --- | ---- | ---- |
| code | 200 | number | - |
| msg | success | string | - |
| data | - | object | - |
| data.data | - | array | - |
| data.data.id | 1 | number | 数据ID |
| data.data.title | 111 | string | 游戏名称 |
| data.data.img | - | string | 游戏图片 |
| data.current_page | 1 | number | - |
| data.total | 1 | number | - |
| data.lastPage | 1 | number | - |
| data.data.favorites | false | boolean | 是否收藏：true是，false否 |

* 失败(200)

```javascript
{
	"code": 200,
	"msg": "success",
	"data": {
		"data": [],
		"current_page": 1,
		"total": 0,
		"lastPage": 0
	}
}
```

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| lang | CN | string | 是 | - |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjYwMDAwL2FwaS91c2VyL2xvZ2luIiwiaWF0IjoxNzUzNzU2NTQxLCJleHAiOjE3NTYzNDg1NDEsIm5iZiI6MTc1Mzc1NjU0MSwianRpIjoiVDRGVnFpSTc0dWhHNGQ2byIsInN1YiI6IjY2MiIsInBydiI6Ijg2NjVhZTk3NzVjZjI2ZjZiOGU0OTZmODZmYTUzNmQ2OGRkNzE4MTgifQ.IS_uy8Kgqv63i5amzxOkTa1Ifh0ltev4yA5N6fYjsKc | string | 是 | - |

**Query**

#### 获取全局参数

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-04-23 16:48:18

> 更新时间: 2026-04-27 12:13:58

```text
暂无描述
```

**接口状态**

> 已完成

**接口URL**

> http://45.200.16.18:60000/api/system/getlist

**请求方式**

> POST

**Content-Type**

> json

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| lang | CN | string | 是 | - |

**请求Body参数**

```javascript
暂无数据
```

**认证方式**

> 继承父级

**响应示例**

* 成功(200)

```javascript
{
	"code": 200,
	"msg": "success",
	"data": {
		"data": {
			"config_lang": [
				{
					"code": "CN",
					"title": "中文简体",
					"img": "https://apis.xh-demo.com/uploads/images/lang/31aa095b-0eab-4148-b32b-6cbc1535c300.webp",
					"status_s": 1
				},
				{
					"code": "TW",
					"title": "中文繁体",
					"img": "https://apis.xh-demo.com/uploads/images/lang/香港圆形旗帜_1775998580.webp",
					"status_s": 0
				},
				{
					"code": "EN",
					"title": "English",
					"img": "https://apis.xh-demo.com/uploads/images/lang/圆形英国国旗_1775998687.webp",
					"status_s": 0
				},
				{
					"code": "JP",
					"title": "日本語",
					"img": "https://apis.xh-demo.com/uploads/images/lang/日本圆形国旗_1775998762.webp",
					"status_s": 0
				},
				{
					"code": "KR",
					"title": "한국인",
					"img": "https://apis.xh-demo.com/uploads/images/lang/韩国国旗圆形版本_1775998901.webp",
					"status_s": 0
				},
				{
					"code": "VI",
					"title": "Tiếng Việt",
					"img": "https://apis.xh-demo.com/uploads/images/lang/越南圆形国旗_1775998936.webp",
					"status_s": 0
				},
				{
					"code": "TH",
					"title": "แบบไทย",
					"img": "https://apis.xh-demo.com/uploads/images/lang/泰国圆形国旗_1775998979.webp",
					"status_s": 0
				},
				{
					"code": "BR",
					"title": "Português",
					"img": "https://apis.xh-demo.com/uploads/images/lang/圆形葡萄牙国旗图标_1775999005.webp",
					"status_s": 0
				},
				{
					"code": "KH",
					"title": "កម្ពុជា។",
					"img": "https://apis.xh-demo.com/uploads/images/lang/柬埔寨圆形国旗_1775999027.webp",
					"status_s": 0
				},
				{
					"code": "ID",
					"title": "Indonesia",
					"img": "https://apis.xh-demo.com/uploads/images/lang/印度圆形国旗_1775999066.webp",
					"status_s": 0
				},
				{
					"code": "MY",
					"title": "မြန်မာဘာသာ",
					"img": "https://apis.xh-demo.com/uploads/images/lang/圆形缅甸国旗_1776147661.webp",
					"status_s": 0
				}
			],
			"config_curr": [
				{
					"code": "CNY",
					"title": "人民币",
					"symbol": "￥",
					"status_s": 1
				}
			],
			"config_site": {
				"id": 1,
				"title": "星汇演示11",
				"logo": "https://apis.xh-demo.com/uploads/images/logo/logo.png",
				"keyword": "星汇演示",
				"desc": "本次新增功能旨在优化操作效率、完善业务场景，提升用户使用体验，适配日常运营及管理需求，无额外操作",
				"service_link": "https://kf.ms-xh.com/index/index/home?business_id=3&groupid=0&special=3&theme=05202d",
				"domain": "xh-bet.com",
				"pc_url": "",
				"h5_url": "",
				"agent_url": "",
				"app_download": "https://app.xh-demo.com/app",
				"apk_download": "",
				"ios_download": "https://app.xh-demo.com/12万12312312.ipa",
				"status": 1,
				"description": "网站正在升级维护，维护时间预计两小时，请耐心等待！!",
				"terminal_login": 1,
				"app_version": "1.111",
				"tg_link": "https://xh-api.com,https://xh-api.com",
				"app_icon": "https://apis.xh-demo.com/uploads/images/app_icon/R.png",
				"app_desc": ""
			},
			"config_reg": [
				{
					"title": "手机号码",
					"code": "phone",
					"status": 0,
					"status_s": 0
				},
				{
					"title": "QQ",
					"code": "qq",
					"status": 0,
					"status_s": 0
				},
				{
					"title": "Telegram",
					"code": "telegram",
					"status": 0,
					"status_s": 0
				},
				{
					"title": "电子邮箱",
					"code": "email",
					"status": 0,
					"status_s": 0
				},
				{
					"title": "真实姓名",
					"code": "name",
					"status": 0,
					"status_s": 0
				},
				{
					"title": "邀请码",
					"code": "invicode",
					"status": 1,
					"status_s": 0
				},
				{
					"title": "安全码/取款码",
					"code": "pay_password",
					"status": 1,
					"status_s": 0
				}
			],
			"config_pic": {
				"id": 1,
				"login_status": 0,
				"reg_status": 0,
				"agent_login_status": 0,
				"admin_login_status": 0,
				"login_error": 1,
				"code_type": 1,
				"pic_width": "145",
				"pic_height": "50",
				"pic_size": "20",
				"pic_digit": "6"
			},
			"config_mail": {
				"id": 1,
				"login_status": 1,
				"reg_status": 0,
				"agent_login_status": 0,
				"admin_login_status": 0,
				"type": 1,
				"expire": 5,
				"frequency": 5
			},
			"config_send": {
				"id": 1,
				"login_status": 1,
				"reg_status": 0,
				"agent_login_status": 0,
				"admin_login_status": 0,
				"type": 1,
				"expire": 5,
				"frequency": 15
			},
			"config_banner": [
				{
					"open": 1,
					"open_url": "http://localhost:8081/nrgl/banner",
					"img": "https://hyoonyenbackfi.yxb2017.com/clientManage/5ccefb0756814841bc61a068a626a21a.jpg?x-oss-process=image/format,webp/quality,q_90",
					"lang": "[\"CN\",\"TW\"]",
					"terminal": 2
				},
				{
					"open": 0,
					"open_url": "",
					"img": "https://hyoonyenbackfi.yxb2017.com/clientManage/8435f6f21bfa4a2890d019dc469da8a0.jpg?x-oss-process=image/format,webp/quality,q_90",
					"lang": "[\"CN\",\"JP\",\"TW\",\"EN\"]",
					"terminal": 1
				},
				{
					"open": 0,
					"open_url": "",
					"img": "https://hyoonyenbackfi.yxb2017.com/clientManage/5ccefb0756814841bc61a068a626a21a.jpg?x-oss-process=image/format,webp/quality,q_90",
					"lang": "[\"CN\",\"JP\",\"TW\",\"EN\"]",
					"terminal": 1
				}
			],
			"config_notice": [
				{
					"id": 17,
					"title": "星汇演示",
					"text": "<p>親愛的客戶：為了您的資金安全，請勿相信以星匯名義自稱的工作人員要求會員在沒有真實收到款的情況下點擊確認📵切記不要將個人賬戶密碼洩露給他人以及進行外租和販賣❌星匯平台也不會以任何郵件形式要求會員轉帳打款❗️以上皆為盜號者，一旦提供將會被修改信息，造成財產損失🥀舉報者皆可在意見反饋提供線索⭕️官方給予獎勵💰如有任何問題，請您聯繫7*24小時在線客服🌷</p>",
					"pop_up": 1,
					"top": 1,
					"terminal": 2
				},
				{
					"id": 19,
					"title": "星汇演示",
					"text": "<p>星汇演示</p>",
					"pop_up": 1,
					"top": 1,
					"terminal": 2
				},
				{
					"id": 21,
					"title": "防骗提醒",
					"text": "<p>所有支付宝出款业务均为官方正规操作！官方客服从不主动联系，绝不索要账号、密码、验证码，更不要求转账。切勿泄露信息、勿转账，谨防被骗！！！</p>",
					"pop_up": 0,
					"top": 0,
					"terminal": 2
				},
				{
					"id": 22,
					"title": "阿斯顿那里可能是",
					"text": "<p>親愛的客戶：為了您的資金安全，請勿相信以星匯名義自稱的工作人員要求會員在沒有真實收到款的情況下點擊確認📵切記不要將個人賬戶密碼洩露給他人以及進行外租和販賣❌星匯平台也不會以任何郵件形式要求會員轉帳打款❗️以上皆為盜號者，一旦提供將會被修改信息，造成財產損失🥀舉報者皆可在意見反饋提供線索⭕️官方給予獎勵💰如有任何問題，請您聯繫7*24小時在線客服🌷</p>",
					"pop_up": 0,
					"top": 0,
					"terminal": 1
				},
				{
					"id": 23,
					"title": "11",
					"text": "<p>1</p>",
					"pop_up": 1,
					"top": 0,
					"terminal": 1
				}
			],
			"config_domain": [
				"http://localhost:8081",
				"http://m.xh-demo.com/?refcode=868",
				"http://pc.xh-demo.com/?refcode=868",
				"http://m.xh-demo.com",
				"https://m1.xh-demo.com",
				"https://m.xh-demo.com",
				""
			],
			"data_list": [
				{
					"key": "CN",
					"value": "中文简体"
				},
				{
					"key": "TW",
					"value": "中文繁体"
				},
				{
					"key": "EN",
					"value": "English"
				},
				{
					"key": "JP",
					"value": "日本語"
				},
				{
					"key": "KR",
					"value": "한국인"
				},
				{
					"key": "VI",
					"value": "Tiếng Việt"
				},
				{
					"key": "TH",
					"value": "แบบไทย"
				},
				{
					"key": "BR",
					"value": "Português"
				},
				{
					"key": "KH",
					"value": "កម្ពុជា។"
				},
				{
					"key": "ID",
					"value": "Indonesia"
				},
				{
					"key": "MY",
					"value": "မြန်မာဘာသာ"
				},
				{
					"key": "MYa",
					"value": "fdsfds"
				},
				{
					"key": "MY1a",
					"value": "fdsfds"
				}
			]
		}
	}
}
```

| 参数名 | 示例值 | 参数类型 | 参数描述 |
| --- | --- | ---- | ---- |
| code | 200 | number | - |
| msg | success | string | 错误信息 |
| data | - | object | - |
| data.data | - | object | - |
| data.data.config_lang | - | array | 语系配置 |
| data.data.config_lang.code | CN | string | 语系标识 |
| data.data.config_lang.title | 中文简体 | string | 语系标题 |
| data.data.config_lang.img | https://apis.xh-demo.com/uploads/images/lang/31aa095b-0eab-4148-b32b-6cbc1535c300.webp | string | 图标 |
| data.data.config_lang.status_s | 1 | number | 是否默认   1是   0否 |
| data.data.config_curr | - | array | 货币配置 |
| data.data.config_curr.code | CNY | string | 货币 |
| data.data.config_curr.title | 人民币 | string | 货币标题 |
| data.data.config_curr.symbol | ￥ | string | 货币符号 |
| data.data.config_curr.status_s | 1 | number | 是否默认   1是   0否 |
| data.data.config_site | - | object | 站点配置 |
| data.data.config_site.id | 1 | number | 数据ID |
| data.data.config_site.title | 星汇演示11 | string | 站点标题 |
| data.data.config_site.logo | https://apis.xh-demo.com/uploads/images/logo/logo.png | string | 站点logo |
| data.data.config_site.keyword | 星汇演示 | string | 关键词 |
| data.data.config_site.desc | 本次新增功能旨在优化操作效率、完善业务场景，提升用户使用体验，适配日常运营及管理需求，无额外操作 | string | 描述 |
| data.data.config_site.service_link | https://kf.ms-xh.com/index/index/home?business_id=3&groupid=0&special=3&theme=05202d | string | 客服链接 |
| data.data.config_site.domain | xh-bet.com | string | 永久域名 |
| data.data.config_site.pc_url | - | string | 电脑 |
| data.data.config_site.h5_url | - | string | H5 |
| data.data.config_site.agent_url | - | string | 代理域名 |
| data.data.config_site.app_download | https://app.xh-demo.com/app | string | APP下载地址 |
| data.data.config_site.apk_download | - | string | apk文件 |
| data.data.config_site.ios_download | https://app.xh-demo.com/12万12312312.ipa | string | ios文件 |
| data.data.config_site.status | 1 | number | 站点状态：1正常，0维护 |
| data.data.config_site.description | 网站正在升级维护，维护时间预计两小时，请耐心等待！! | string | 维护描述 |
| data.data.config_site.terminal_login | 1 | integer | 多端登陆：0不允许，1允许 |
| data.data.config_site.app_version | 1.111 | string | app版本号 |
| data.data.config_site.tg_link | https://xh-api.com,https://xh-api.com | string | TG客服链接，支持多个，使用小写逗号分, |
| data.data.config_site.app_icon | https://apis.xh-demo.com/uploads/images/app_icon/R.png | string | APP图标 |
| data.data.config_site.app_desc | - | string | app下载 |
| data.data.config_reg | - | array | 注册配置 |
| data.data.config_reg.title | 手机号码 | string | 标题 |
| data.data.config_reg.code | phone | string | 标识 |
| data.data.config_reg.status | 0 | number | 是否启用：1是   0  否 |
| data.data.config_reg.status_s | 0 | number | 是否必填：1是   0  否 |
| data.data.config_pic | - | object | 图形验证码配置 |
| data.data.config_pic.id | 1 | number | 数据ID |
| data.data.config_pic.login_status | 0 | number | 用户登录使用：1是，0否 |
| data.data.config_pic.reg_status | 0 | number | 注册使用：1是，0否 |
| data.data.config_pic.agent_login_status | 0 | number | 代理登陆使用：1正常0，禁用 |
| data.data.config_pic.admin_login_status | 0 | number | 后台登陆使用：1正常0，禁用 |
| data.data.config_pic.login_error | 1 | number | 登陆失败3次才使用：1是，0否，优先级高于  login_status ，同时login_status 也要开启 |
| data.data.config_pic.code_type | 1 | number | 验证码类型：1图形验证码，0滑行验证码 |
| data.data.config_pic.pic_width | 145 | string | - |
| data.data.config_pic.pic_height | 50 | string | - |
| data.data.config_pic.pic_size | 20 | string | - |
| data.data.config_pic.pic_digit | 6 | string | - |
| data.data.config_mail | - | object | 电邮配置 |
| data.data.config_mail.id | 1 | number | 数据ID |
| data.data.config_mail.login_status | 1 | number | 登陆使用：1是，0否 |
| data.data.config_mail.reg_status | 0 | number | 注册使用：1是，0否 |
| data.data.config_mail.agent_login_status | 0 | number | 代理使用：1是，0否 |
| data.data.config_mail.admin_login_status | 0 | number | 后台使用：1是，0否 |
| data.data.config_mail.type | 1 | number | - |
| data.data.config_mail.expire | 5 | number | 超时时间，建议设置为按钮倒计时，单位：分钟 |
| data.data.config_mail.frequency | 5 | number | - |
| data.data.config_send | - | object | 手机验证码配置 |
| data.data.config_send.id | 1 | number | 数据ID |
| data.data.config_send.login_status | 1 | number | 会员登录：1开启，0关闭 |
| data.data.config_send.reg_status | 0 | number | 会员注册：1开启，0关闭 |
| data.data.config_send.agent_login_status | 0 | number | 代理登录：1开启，0关闭 |
| data.data.config_send.admin_login_status | 0 | number | 后台登录：1开启，0关闭 |
| data.data.config_send.type | 1 | number | - |
| data.data.config_send.expire | 5 | number | 验证码有效期 |
| data.data.config_send.frequency | 15 | number | 24小时内对单一手机号发次数，推荐设置20次，0位不限制 |
| data.data.config_banner | - | array | 轮播图配置 |
| data.data.config_banner.open | 1 | number | 是否在新窗口打开url：1是，0否 |
| data.data.config_banner.open_url | http://localhost:8081/nrgl/banner | string | 链接 |
| data.data.config_banner.img | https://hyoonyenbackfi.yxb2017.com/clientManage/5ccefb0756814841bc61a068a626a21a.jpg?x-oss-process=image/format,webp/quality,q_90 | string | 图片地址 |
| data.data.config_banner.lang | ["CN","TW"] | string | - |
| data.data.config_banner.terminal | 2 | number | - |
| data.data.config_notice | - | array | 公告 |
| data.data.config_notice.id | 17 | number | 数据ID |
| data.data.config_notice.title | 星汇演示 | string | 公告 |
| data.data.config_notice.text | <p>親愛的客戶：為了您的資金安全，請勿相信以星匯名義自稱的工作人員要求會員在沒有真實收到款的情況下點擊確認📵切記不要將個人賬戶密碼洩露給他人以及進行外租和販賣❌星匯平台也不會以任何郵件形式要求會員轉帳打款❗️以上皆為盜號者，一旦提供將會被修改信息，造成財產損失🥀舉報者皆可在意見反饋提供線索⭕️官方給予獎勵💰如有任何問題，請您聯繫7*24小時在線客服🌷</p> | string | 公告内容 |
| data.data.config_notice.pop_up | 1 | number | 是否弹窗：1是，0否 |
| data.data.config_notice.top | 1 | number | 是否置顶：1是，0否 |
| data.data.config_notice.terminal | 2 | integer | 终端：1 通用，2 web，3 h5，4 APP |
| data.data.config_domain | - | array | 代理专属域名，演示域名，实际是不带参数的 |
| data.data.data_list | - | array | 扩展 |
| data.data.data_list.key | CN | string | 标识 |
| data.data.data_list.value | 中文简体 | string | 值 |

* 失败(200)

```javascript
暂无数据
```

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| lang | CN | string | 是 | - |

**Query**

#### 获取推荐游戏

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2026-01-28 13:48:23

> 更新时间: 2026-01-28 13:49:08

```text
暂无描述
```

**接口状态**

> 已完成

**接口URL**

> http://45.200.16.18:60000/api/interface/reco

**请求方式**

> POST

**Content-Type**

> none

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| lang | CN | string | 是 | - |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjYwMDAwL2FwaS91c2VyL2xvZ2luIiwiaWF0IjoxNzUzNzU2NTQxLCJleHAiOjE3NTYzNDg1NDEsIm5iZiI6MTc1Mzc1NjU0MSwianRpIjoiVDRGVnFpSTc0dWhHNGQ2byIsInN1YiI6IjY2MiIsInBydiI6Ijg2NjVhZTk3NzVjZjI2ZjZiOGU0OTZmODZmYTUzNmQ2OGRkNzE4MTgifQ.IS_uy8Kgqv63i5amzxOkTa1Ifh0ltev4yA5N6fYjsKc | string | 是 | - |

**认证方式**

> 继承父级

**响应示例**

* 成功(200)

```javascript
{
	"code": 200,
	"msg": "success",
	"data": [
		{
			"id": 36,
			"code": "live",
			"title": "我是标题",
			"gamecode": "1",
			"game": "1",
			"label": "[\"new\",\"reco\"]",
			"img": ""
		}
	]
}
```

| 参数名 | 示例值 | 参数类型 | 参数描述 |
| --- | --- | ---- | ---- |
| code | 200 | number | - |
| msg | success | string | - |
| data | - | array | - |
| data.id | 36 | number | 数据ID |
| data.code | live | string | 分类标识 |
| data.title | 我是标题 | string | 分类名称 |
| data.gamecode | 1 | string | 二级分类标识 |
| data.game | 1 | string | 二级分类代码 |
| data.label | ["new","reco"] | string | - |
| data.img | - | string | 图片 |
| data.favorites | false | boolean | 是否收藏：true是，false否，此参数只针对登陆用户有效 |

* 失败(200)

```javascript
暂无数据
```

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| lang | CN | string | 是 | - |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjYwMDAwL2FwaS91c2VyL2xvZ2luIiwiaWF0IjoxNzUzNzU2NTQxLCJleHAiOjE3NTYzNDg1NDEsIm5iZiI6MTc1Mzc1NjU0MSwianRpIjoiVDRGVnFpSTc0dWhHNGQ2byIsInN1YiI6IjY2MiIsInBydiI6Ijg2NjVhZTk3NzVjZjI2ZjZiOGU0OTZmODZmYTUzNmQ2OGRkNzE4MTgifQ.IS_uy8Kgqv63i5amzxOkTa1Ifh0ltev4yA5N6fYjsKc | string | 是 | - |

**Query**

### 优惠活动

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-04-13 11:11:31

> 更新时间: 2025-10-15 18:05:10

```text
暂无描述
```

**目录Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| 暂无参数 |

**目录Query参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| 暂无参数 |

**目录Body参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| 暂无参数 |

**目录认证信息**

> 继承父级

**Query**

#### 活动分类

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-04-13 11:11:31

> 更新时间: 2025-04-23 21:51:35

```text
暂无描述
```

**接口状态**

> 已完成

**接口URL**

> http://45.200.16.18:60000/api/activity/class

**请求方式**

> POST

**Content-Type**

> json

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| lang | CN | string | 是 | - |

**请求Body参数**

```javascript
暂无数据
```

**认证方式**

> 继承父级

**响应示例**

* 成功(200)

```javascript
{
	"code": 200,
	"msg": "success",
	"data": [
		{
			"id": 33,
			"title": "默认分类名称"
		},
		{
			"id": 34,
			"title": "默官方认分类名称aaa"
		},
		{
			"id": 37,
			"title": "默认分类名称"
		}
	]
}
```

* 失败(200)

```javascript
暂无数据
```

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| lang | CN | string | 是 | - |

**Query**

#### 活动列表

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-04-13 11:11:31

> 更新时间: 2025-04-13 11:11:31

```text
暂无描述
```

**接口状态**

> 已完成

**接口URL**

> http://45.200.16.18:65535/api/activity/list

**请求方式**

> POST

**Content-Type**

> json

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| lang | CN | string | 是 | - |

**请求Body参数**

```javascript
{
    "id": 34
}
```

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| id | 34 | number | 否 | 活动分类数据ID，不传则返回全部 |

**认证方式**

> 继承父级

**响应示例**

* 成功(200)

```javascript
{
	"code": 200,
	"msg": "success",
	"data": [
		{
			"id": 38,
			"type": 1,
			"start_time": "2024-08-28 11:06:24",
			"end_time": "2024-08-28 11:06:24",
			"lasting": 1,
			"multiple": 5,
			"title": "默认分类名称1",
			"content": "活动内容",
			"img": ""
		},
		{
			"id": 41,
			"type": 1,
			"start_time": "2024-08-18 21:31:10",
			"end_time": "2024-08-19 21:31:10",
			"lasting": 1,
			"multiple": 5,
			"title": "",
			"content": "",
			"img": ""
		},
		{
			"id": 39,
			"type": 1,
			"start_time": "2024-08-19 04:54:38",
			"end_time": "2024-08-19 04:54:38",
			"lasting": 0,
			"multiple": 0,
			"title": "",
			"content": "",
			"img": ""
		},
		{
			"id": 40,
			"type": 1,
			"start_time": "2024-08-19 04:55:27",
			"end_time": "2024-08-19 04:55:27",
			"lasting": 1,
			"multiple": 0,
			"title": "",
			"content": "",
			"img": ""
		}
	]
}
```

| 参数名 | 示例值 | 参数类型 | 参数描述 |
| --- | --- | ---- | ---- |
| code | 200 | number | - |
| msg | success | string | - |
| data | - | array | - |
| data.id | 38 | number | 数据ID |
| data.type | 1 | number | 领取方式：1系统派发，2手动申请 |
| data.start_time | 2024-08-28 11:06:24 | string | 活动开始时间 |
| data.end_time | 2024-08-28 11:06:24 | string | 活动结束时间 |
| data.lasting | 1 | number | 活动长时间有效：1是，0否，该参数为1时开始时间和结束时间失效 |
| data.multiple | 5 | number | 倍数 |
| data.title | 默认分类名称1 | string | 活动标题 |
| data.content | 活动内容 | string | 活动内容 |
| data.img | - | string | 图片 |

* 失败(200)

```javascript
暂无数据
```

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| lang | CN | string | 是 | - |

**Query**

#### 获取活动详情

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-04-13 11:11:31

> 更新时间: 2025-10-15 18:05:39

```text
暂无描述
```

**接口状态**

> 已完成

**接口URL**

> http://45.200.16.18:60000/api/activity/details?lang=CN

**请求方式**

> POST

**Content-Type**

> json

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| lang | CN | string | 是 | - |

**请求Query参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| lang | CN | string | 是 | - |

**请求Body参数**

```javascript
{
    "id": 45
}
```

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| id | 34 | number | 否 | 活动分类数据ID，不传则返回全部 |

**认证方式**

> 继承父级

**响应示例**

* 成功(200)

```javascript
{
	"code": 200,
	"msg": "success",
	"data": [
		{
			"id": 46,
			"type": 1,
			"start_time": "2024-09-22 17:14:31",
			"end_time": "2024-09-22 17:14:31",
			"lasting": 0,
			"multiple": 0,
			"title": "得到的",
			"content": "对方的方式分1",
			"img": "https://xhapi.xh-demo.com/uploads/images/pc_img/202409/22/5d939c805a7675e0c2ab486d70a9545b.jpg"
		}
	]
}
```

| 参数名 | 示例值 | 参数类型 | 参数描述 |
| --- | --- | ---- | ---- |
| code | 200 | number | - |
| msg | success | string | - |
| data | - | array | - |
| data.id | 46 | number | 数据ID |
| data.type | 1 | number | 领取方式：1系统派发，2手动申请 |
| data.start_time | 2024-09-22 17:14:31 | string | 活动开始时间 |
| data.end_time | 2024-09-22 17:14:31 | string | 活动结束时间 |
| data.lasting | 0 | number | 活动长时间有效：1是，0否，该参数为1时开始时间和结束时间失效 |
| data.multiple | 0 | number | 倍数 |
| data.title | 得到的 | string | 活动标题 |
| data.content | 对方的方式分1 | string | 活动内容 |
| data.img | https://xhapi.xh-demo.com/uploads/images/pc_img/202409/22/5d939c805a7675e0c2ab486d70a9545b.jpg | string | 图片 |

* 失败(200)

```javascript
暂无数据
```

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| lang | CN | string | 是 | - |

**Query**

#### 申请活动

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-04-13 11:11:31

> 更新时间: 2025-04-13 11:11:31

```text
暂无描述
```

**接口状态**

> 已完成

**接口URL**

> http://45.200.16.18:65535/api/activity/apply

**请求方式**

> POST

**Content-Type**

> json

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE3Mzo2NTUzNS9tL3VzZXIvbG9naW4iLCJpYXQiOjE3MjQ4MTkyMjcsImV4cCI6MTcyNzQxMTIyNywibmJmIjoxNzI0ODE5MjI3LCJqdGkiOiI1OFVWQlNXMXpZU3lUS0JOIiwic3ViIjoiNjU2IiwicHJ2IjoiODY2NWFlOTc3NWNmMjZmNmI4ZTQ5NmY4NmZhNTM2ZDY4ZGQ3MTgxOCJ9.utQQomZB2RjePNsy7Zz5TmYawmHkCeVD0aOKNe30Zsc | string | 是 | - |
| lang | CN | string | 是 | - |

**请求Body参数**

```javascript
{
    "id": 38
}
```

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| id | 38 | number | 是 | 活动数据ID |

**认证方式**

> 继承父级

**响应示例**

* 成功(200)

```javascript
{
	"code": 200,
	"msg": "申请成功，请等待客服审核",
	"data": []
}
```

* 失败(200)

```javascript
{
	"code": 0,
	"msg": "您已申请过该活动，请等待客服审核"
}
```

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE3Mzo2NTUzNS9tL3VzZXIvbG9naW4iLCJpYXQiOjE3MjQ4MTkyMjcsImV4cCI6MTcyNzQxMTIyNywibmJmIjoxNzI0ODE5MjI3LCJqdGkiOiI1OFVWQlNXMXpZU3lUS0JOIiwic3ViIjoiNjU2IiwicHJ2IjoiODY2NWFlOTc3NWNmMjZmNmI4ZTQ5NmY4NmZhNTM2ZDY4ZGQ3MTgxOCJ9.utQQomZB2RjePNsy7Zz5TmYawmHkCeVD0aOKNe30Zsc | string | 是 | - |
| lang | CN | string | 是 | - |

**Query**

#### 活动申请记录

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-04-13 11:11:31

> 更新时间: 2025-04-26 11:36:34

```text
暂无描述
```

**接口状态**

> 已完成

**接口URL**

> http://45.200.16.18:60000/api/activity/record

**请求方式**

> POST

**Content-Type**

> json

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE3Mzo2NTUzNS9tL3VzZXIvbG9naW4iLCJpYXQiOjE3MjQ4MTkyMjcsImV4cCI6MTcyNzQxMTIyNywibmJmIjoxNzI0ODE5MjI3LCJqdGkiOiI1OFVWQlNXMXpZU3lUS0JOIiwic3ViIjoiNjU2IiwicHJ2IjoiODY2NWFlOTc3NWNmMjZmNmI4ZTQ5NmY4NmZhNTM2ZDY4ZGQ3MTgxOCJ9.utQQomZB2RjePNsy7Zz5TmYawmHkCeVD0aOKNe30Zsc | string | 是 | - |
| lang | CN | string | 是 | - |

**请求Body参数**

```javascript
{
    "page": 1,
    "size": 10
}
```

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| page | 1 | number | 是 | - |
| size | 10 | number | 是 | - |

**认证方式**

> 继承父级

**响应示例**

* 成功(200)

```javascript
{
	"code": 200,
	"msg": "success",
	"data": {
		"data": [
			{
				"username": "dd46461",
				"status": 1,
				"apply_time": "2024-08-28 05:00:09",
				"title": "默认分类名称1"
			},
			{
				"username": "dd46461",
				"status": 2,
				"apply_time": "2024-08-28 04:59:42",
				"title": "默认分类名称1"
			}
		],
		"current_page": 1,
		"total": 2,
		"lastPage": 1
	}
}
```

| 参数名 | 示例值 | 参数类型 | 参数描述 |
| --- | --- | ---- | ---- |
| code | 200 | number | - |
| msg | success | string | - |
| data | - | object | - |
| data.data | - | array | - |
| data.data.username | dd46461 | string | 会员账号 |
| data.data.status | 1 | number | 状态：1申请中，2申请通过，3申请拒绝 |
| data.data.apply_time | 2024-08-28 05:00:09 | string | 申请时间 |
| data.data.title | 默认分类名称1 | string | 申请活动标题 |
| data.current_page | 1 | number | - |
| data.total | 2 | number | - |
| data.lastPage | 1 | number | - |

* 失败(200)

```javascript
暂无数据
```

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE3Mzo2NTUzNS9tL3VzZXIvbG9naW4iLCJpYXQiOjE3MjQ4MTkyMjcsImV4cCI6MTcyNzQxMTIyNywibmJmIjoxNzI0ODE5MjI3LCJqdGkiOiI1OFVWQlNXMXpZU3lUS0JOIiwic3ViIjoiNjU2IiwicHJ2IjoiODY2NWFlOTc3NWNmMjZmNmI4ZTQ5NmY4NmZhNTM2ZDY4ZGQ3MTgxOCJ9.utQQomZB2RjePNsy7Zz5TmYawmHkCeVD0aOKNe30Zsc | string | 是 | - |
| lang | CN | string | 是 | - |

**Query**

### 三方游戏相关

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-04-13 11:11:31

> 更新时间: 2025-04-13 11:11:31

```text
暂无描述
```

**目录Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| 暂无参数 |

**目录Query参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| 暂无参数 |

**目录Body参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| 暂无参数 |

**目录认证信息**

> 继承父级

**Query**

#### 启动游戏

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-04-13 11:11:31

> 更新时间: 2026-03-24 00:19:04

```text
暂无描述
```

**接口状态**

> 已完成

**接口URL**

> http://45.200.16.18:60000/api/game/login

**请求方式**

> POST

**Content-Type**

> json

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjYwMDAwL2FwaS91c2VyL2xvZ2luIiwiaWF0IjoxNzc0MjgxOTYzLCJleHAiOjE3NzY4NzM5NjMsIm5iZiI6MTc3NDI4MTk2MywianRpIjoiMUdmNHlWakVJRk5tQ0hQNSIsInN1YiI6IjgxNyIsInBydiI6Ijg2NjVhZTk3NzVjZjI2ZjZiOGU0OTZmODZmYTUzNmQ2OGRkNzE4MTgifQ.ipbGOyEIxeRDXpLuLediCxEq04jqFkUPhlYsqb4N71Y | string | 是 | - |
| lang | CN | string | 是 | - |

**请求Body参数**

```javascript
{
    "id": 36,
    "mobile": 1
}
```

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| id | 36 | number | 是 | 首页游戏数据ID |
| mobile | 1 | number | 否 | 终端：0pc，1 wap，默认 0 |

**认证方式**

> 继承父级

**响应示例**

* 成功(200)

```javascript
{
	"code": 200,
	"msg": "ok",
	"data": {
		"url": "https://msgm69c167ac2d080.site2.erdfcv.xyz",
		"nesting": false
	}
}
```

| 参数名 | 示例值 | 参数类型 | 参数描述 |
| --- | --- | ---- | ---- |
| code | 200 | number | - |
| msg | ok | string | - |
| data | - | object | - |
| data.url | https://msgm69c167ac2d080.site2.erdfcv.xyz | string | 游戏URL |
| data.nesting | false | boolean | 是否支持嵌套：true 是，false否 |

* 失败(200)

```javascript
{
	"code": 0,
	"msg": "商户密钥错误"
}
```

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjYwMDAwL2FwaS91c2VyL2xvZ2luIiwiaWF0IjoxNzc0MjgxOTYzLCJleHAiOjE3NzY4NzM5NjMsIm5iZiI6MTc3NDI4MTk2MywianRpIjoiMUdmNHlWakVJRk5tQ0hQNSIsInN1YiI6IjgxNyIsInBydiI6Ijg2NjVhZTk3NzVjZjI2ZjZiOGU0OTZmODZmYTUzNmQ2OGRkNzE4MTgifQ.ipbGOyEIxeRDXpLuLediCxEq04jqFkUPhlYsqb4N71Y | string | 是 | - |
| lang | CN | string | 是 | - |

**Query**

#### 一键刷新余额

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-04-13 11:11:31

> 更新时间: 2026-03-25 20:18:21

```text
暂无描述
```

**接口状态**

> 已完成

**接口URL**

> http://45.200.16.18:60000/api/game/balance

**请求方式**

> POST

**Content-Type**

> json

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL2FwaXMueGgtZGVtby5jb20vYXBpL3VzZXIvbG9naW4iLCJpYXQiOjE3NzQ0NDA0MzgsImV4cCI6MTc3NzAzMjQzOCwibmJmIjoxNzc0NDQwNDM4LCJqdGkiOiI3a05lcUp2SXo2UTdibkhoIiwic3ViIjoiODEwIiwicHJ2IjoiODY2NWFlOTc3NWNmMjZmNmI4ZTQ5NmY4NmZhNTM2ZDY4ZGQ3MTgxOCJ9.TGO8mv9dQiotkBulv9yAiLteY4eQ9N9edHNfabAbubI | string | 是 | - |
| lang | CN | string | 是 | - |

**请求Body参数**

```javascript
暂无数据
```

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| id | 36 | number | 是 | 接口数据ID |

**认证方式**

> 继承父级

**响应示例**

* 成功(200)

```javascript
{
	"code": 200,
	"msg": "success",
	"data": [
		{
			"id": 1,
			"title": "PA接口",
			"code": "AG",
			"money": 0
		},
		{
			"id": 2,
			"title": "PA电子",
			"code": "AGDZ",
			"money": 0
		},
		{
			"id": 3,
			"title": "DG视讯",
			"code": "DG",
			"money": 0
		},
		{
			"id": 4,
			"title": "乐游棋牌",
			"code": "LEG",
			"money": 0
		},
		{
			"id": 5,
			"title": "沙巴体育",
			"code": "IBC",
			"money": 0
		},
		{
			"id": 6,
			"title": "三晟体育",
			"code": "SS",
			"money": 0
		},
		{
			"id": 7,
			"title": "雷火电竞",
			"code": "TFG",
			"money": 0
		},
		{
			"id": 8,
			"title": "百盛棋牌",
			"code": "BSQP",
			"money": 0
		},
		{
			"id": 9,
			"title": "欧博视讯",
			"code": "AB",
			"money": 0
		},
		{
			"id": 10,
			"title": "FB体育",
			"code": "FB",
			"money": 0
		},
		{
			"id": 11,
			"title": "CQ9电子",
			"code": "CQ9",
			"money": 0
		},
		{
			"id": 12,
			"title": "CQ9电子",
			"code": "CQ9S",
			"money": 0
		},
		{
			"id": 13,
			"title": "CR体育",
			"code": "CR",
			"money": 0
		},
		{
			"id": 14,
			"title": "DB捕鱼",
			"code": "DBBY",
			"money": 0
		},
		{
			"id": 15,
			"title": "DB电子",
			"code": "DBDZ",
			"money": 0
		},
		{
			"id": 16,
			"title": "DB视讯",
			"code": "DBZR",
			"money": 0
		},
		{
			"id": 17,
			"title": "VR彩票",
			"code": "VR",
			"money": 0
		},
		{
			"id": 18,
			"title": "天成彩票",
			"code": "TCG",
			"money": 0
		},
		{
			"id": 19,
			"title": "开元棋牌",
			"code": "KY",
			"money": 0
		},
		{
			"id": 20,
			"title": "大唐棋牌",
			"code": "DTQP",
			"money": 0
		},
		{
			"id": 21,
			"title": "美天棋牌",
			"code": "MT",
			"money": 0
		},
		{
			"id": 22,
			"title": "PP电子",
			"code": "PP",
			"money": 0
		},
		{
			"id": 23,
			"title": "PP电子",
			"code": "PPS",
			"money": 0
		},
		{
			"id": 24,
			"title": "TP电子",
			"code": "TP",
			"money": 0
		},
		{
			"id": 25,
			"title": "FG电子",
			"code": "FG",
			"money": 0
		},
		{
			"id": 26,
			"title": "VG棋牌",
			"code": "VG",
			"money": 0
		},
		{
			"id": 27,
			"title": "博乐棋牌",
			"code": "BL",
			"money": 0
		},
		{
			"id": 28,
			"title": "BBIN电子",
			"code": "BBDZ",
			"money": 0
		},
		{
			"id": 29,
			"title": "BBIN捕鱼",
			"code": "BBBY",
			"money": 0
		},
		{
			"id": 30,
			"title": "BBIN视讯",
			"code": "BBZR",
			"money": 0
		},
		{
			"id": 31,
			"title": "BBIN彩票",
			"code": "BBCP",
			"money": 0
		},
		{
			"id": 32,
			"title": "BBIN体育",
			"code": "BBTY",
			"money": 0
		},
		{
			"id": 33,
			"title": "BBIN棋牌",
			"code": "BBQP",
			"money": 0
		},
		{
			"id": 34,
			"title": "小艾电竞",
			"code": "IA",
			"money": "0.0000"
		},
		{
			"id": 35,
			"title": "JOKER电子",
			"code": "JOKER",
			"money": "0.0000"
		},
		{
			"id": 36,
			"title": "KA电子",
			"code": "KA",
			"money": "0.0000"
		},
		{
			"id": 37,
			"title": "MG电子",
			"code": "MG",
			"money": "0.0000"
		},
		{
			"id": 38,
			"title": "DB电竞",
			"code": "DBDJ",
			"money": "0.0000"
		},
		{
			"id": 39,
			"title": "DB体育",
			"code": "DBTY",
			"money": "0.0000"
		},
		{
			"id": 40,
			"title": "DB彩票",
			"code": "DBCP",
			"money": "0.0000"
		},
		{
			"id": 41,
			"title": "DG电子",
			"code": "DGDZ",
			"money": "0.0000"
		},
		{
			"id": 42,
			"title": "PG电子",
			"code": "PG",
			"money": "0.0000"
		},
		{
			"id": 43,
			"title": "PG电子",
			"code": "PGA",
			"money": "0.0000"
		},
		{
			"id": 44,
			"title": "PG电子",
			"code": "PGS",
			"money": "0.0000"
		},
		{
			"id": 45,
			"title": "完美视讯",
			"code": "WMLIVE",
			"money": "0.0000"
		},
		{
			"id": 46,
			"title": "世界体育",
			"code": "SJTY",
			"money": "0.0000"
		},
		{
			"id": 47,
			"title": "高登棋牌",
			"code": "GDQ",
			"money": "0.0000"
		},
		{
			"id": 48,
			"title": "JDB电子",
			"code": "JDB",
			"money": "0.0000"
		},
		{
			"id": 49,
			"title": "JDB电子",
			"code": "JDBS",
			"money": "0.0000"
		},
		{
			"id": 50,
			"title": "SEXY视讯",
			"code": "SEXY",
			"money": "0.0000"
		},
		{
			"id": 51,
			"title": "发财电子",
			"code": "FC",
			"money": "0.0000"
		},
		{
			"id": 52,
			"title": "发财电子",
			"code": "FCS",
			"money": "0.0000"
		},
		{
			"id": 53,
			"title": "大满贯电子",
			"code": "MW",
			"money": "0.0000"
		},
		{
			"id": 54,
			"title": "吉利电子",
			"code": "JILI",
			"money": "0.0000"
		},
		{
			"id": 55,
			"title": "吉利电子",
			"code": "JILIS",
			"money": "0.0000"
		},
		{
			"id": 56,
			"title": "PS电子",
			"code": "PS",
			"money": "0.0000"
		},
		{
			"id": 57,
			"title": "沙龙SA视讯",
			"code": "SA",
			"money": "0.0000"
		},
		{
			"id": 58,
			"title": "BG视讯",
			"code": "BGZR",
			"money": "0.0000"
		},
		{
			"id": 59,
			"title": "BG捕鱼",
			"code": "BGBY",
			"money": "0.0000"
		},
		{
			"id": 60,
			"title": "IM体育",
			"code": "IM",
			"money": "0.0000"
		},
		{
			"id": 61,
			"title": "SBO体育",
			"code": "SBO",
			"money": "0.0000"
		},
		{
			"id": 62,
			"title": "SW电子",
			"code": "SW",
			"money": "0.0000"
		},
		{
			"id": 63,
			"title": "GPS电子",
			"code": "GPS",
			"money": "0.0000"
		},
		{
			"id": 64,
			"title": "WE视讯",
			"code": "WELIVE",
			"money": "0.0000"
		},
		{
			"id": 65,
			"title": "AceWin电子",
			"code": "AW",
			"money": "0.0000"
		},
		{
			"id": 66,
			"title": "SG电子",
			"code": "SG",
			"money": "0.0000"
		},
		{
			"id": 67,
			"title": "保利体育",
			"code": "POLY",
			"money": "0.0000"
		},
		{
			"id": 68,
			"title": "CG电子",
			"code": "CG",
			"money": "0.0000"
		},
		{
			"id": 69,
			"title": "EVO视讯",
			"code": "EVO",
			"money": "0.0000"
		},
		{
			"id": 70,
			"title": "RSG电子",
			"code": "RSG",
			"money": "0.0000"
		},
		{
			"id": 71,
			"title": "DS88体育",
			"code": "DSTY",
			"money": "0.0000"
		},
		{
			"id": 72,
			"title": "GM电子",
			"code": "GM",
			"money": "0.0000"
		},
		{
			"id": 73,
			"title": "平博体育",
			"code": "PB",
			"money": "0.0000"
		},
		{
			"id": 74,
			"title": "皇冠体育",
			"code": "HG",
			"money": "0.0000"
		},
		{
			"id": 75,
			"title": "GD电子",
			"code": "GD",
			"money": "0.0000"
		},
		{
			"id": 76,
			"title": "BET视讯",
			"code": "BET",
			"money": "0.0000"
		},
		{
			"id": 77,
			"title": "PT电子",
			"code": "PT",
			"money": "0.0000"
		},
		{
			"id": 78,
			"title": "凯旋棋牌",
			"code": "KX",
			"money": "0.0000"
		},
		{
			"id": 79,
			"title": "DB棋牌",
			"code": "DBQP",
			"money": "0.0000"
		},
		{
			"id": 80,
			"title": "MP棋牌",
			"code": "MP",
			"money": "0.0000"
		},
		{
			"id": 81,
			"title": "BG棋牌",
			"code": "BGQP",
			"money": "0.0000"
		},
		{
			"id": 82,
			"title": "SPINIX电子",
			"code": "SP",
			"money": "0.0000"
		},
		{
			"id": 83,
			"title": "HW电子",
			"code": "HW",
			"money": "0.0000"
		},
		{
			"id": 84,
			"title": "双赢彩票",
			"code": "SGWIN",
			"money": "0.0000"
		},
		{
			"id": 85,
			"title": "开元体育",
			"code": "KYTY",
			"money": "0.0000"
		},
		{
			"id": 86,
			"title": "CC彩票",
			"code": "CCCP",
			"money": "0.0000"
		},
		{
			"id": 87,
			"title": "GLC电子",
			"code": "GLC",
			"money": "0.0000"
		},
		{
			"id": 88,
			"title": "OG视讯",
			"code": "OG",
			"money": "0.0000"
		},
		{
			"id": 89,
			"title": "WG电子",
			"code": "WGS",
			"money": "0.0000"
		}
	]
}
```

| 参数名 | 示例值 | 参数类型 | 参数描述 |
| --- | --- | ---- | ---- |
| code | 200 | number | - |
| msg | success | string | - |
| data | - | object | - |
| data.id | 1 | number | 数据id |
| data.title | PA接口 | string | 接口名称 |
| data.code | AG | string | 接口 |
| data.money | 0 | number | 余额 |

* 失败(200)

```javascript
{
	"code": 0,
	"msg": "商户密钥错误"
}
```

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL2FwaXMueGgtZGVtby5jb20vYXBpL3VzZXIvbG9naW4iLCJpYXQiOjE3NzQ0NDA0MzgsImV4cCI6MTc3NzAzMjQzOCwibmJmIjoxNzc0NDQwNDM4LCJqdGkiOiI3a05lcUp2SXo2UTdibkhoIiwic3ViIjoiODEwIiwicHJ2IjoiODY2NWFlOTc3NWNmMjZmNmI4ZTQ5NmY4NmZhNTM2ZDY4ZGQ3MTgxOCJ9.TGO8mv9dQiotkBulv9yAiLteY4eQ9N9edHNfabAbubI | string | 是 | - |
| lang | CN | string | 是 | - |

**Query**

#### 一键回收余额

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-04-13 11:11:31

> 更新时间: 2025-10-15 18:05:56

```text
暂无描述
```

**接口状态**

> 已完成

**接口URL**

> http://45.200.16.18:60000/api/game/all_trans

**请求方式**

> POST

**Content-Type**

> json

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE3Mzo2NTUzNS9tL3VzZXIvbG9naW4iLCJpYXQiOjE3MjQ4MTkyMjcsImV4cCI6MTcyNzQxMTIyNywibmJmIjoxNzI0ODE5MjI3LCJqdGkiOiI1OFVWQlNXMXpZU3lUS0JOIiwic3ViIjoiNjU2IiwicHJ2IjoiODY2NWFlOTc3NWNmMjZmNmI4ZTQ5NmY4NmZhNTM2ZDY4ZGQ3MTgxOCJ9.utQQomZB2RjePNsy7Zz5TmYawmHkCeVD0aOKNe30Zsc | string | 是 | - |
| lang | CN | string | 是 | - |

**请求Body参数**

```javascript
暂无数据
```

**认证方式**

> 继承父级

**响应示例**

* 成功(200)

```javascript
{
	"code": 200,
	"msg": "一键回收成功",
	"data": []
}
```

| 参数名 | 示例值 | 参数类型 | 参数描述 |
| --- | --- | ---- | ---- |
| code | 200 | number | - |
| msg | ok | string | - |
| data | - | object | - |
| data.balance | 0.00 | string | 余额 |

* 失败(200)

```javascript
{
	"code": 0,
	"msg": "商户密钥错误"
}
```

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE3Mzo2NTUzNS9tL3VzZXIvbG9naW4iLCJpYXQiOjE3MjQ4MTkyMjcsImV4cCI6MTcyNzQxMTIyNywibmJmIjoxNzI0ODE5MjI3LCJqdGkiOiI1OFVWQlNXMXpZU3lUS0JOIiwic3ViIjoiNjU2IiwicHJ2IjoiODY2NWFlOTc3NWNmMjZmNmI4ZTQ5NmY4NmZhNTM2ZDY4ZGQ3MTgxOCJ9.utQQomZB2RjePNsy7Zz5TmYawmHkCeVD0aOKNe30Zsc | string | 是 | - |
| lang | CN | string | 是 | - |

**Query**

#### 手动转入

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-04-13 11:11:31

> 更新时间: 2025-04-13 11:11:31

```text
暂无描述
```

**接口状态**

> 已完成

**接口URL**

> http://45.200.16.18:65535/api/game/deposit

**请求方式**

> POST

**Content-Type**

> json

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE3Mzo2NTUzNS9tL3VzZXIvbG9naW4iLCJpYXQiOjE3MjQ4MTkyMjcsImV4cCI6MTcyNzQxMTIyNywibmJmIjoxNzI0ODE5MjI3LCJqdGkiOiI1OFVWQlNXMXpZU3lUS0JOIiwic3ViIjoiNjU2IiwicHJ2IjoiODY2NWFlOTc3NWNmMjZmNmI4ZTQ5NmY4NmZhNTM2ZDY4ZGQ3MTgxOCJ9.utQQomZB2RjePNsy7Zz5TmYawmHkCeVD0aOKNe30Zsc | string | 是 | - |
| lang | CN | string | 是 | - |

**请求Body参数**

```javascript
{
    "id": 41,
    "money": 10
}
```

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| id | 36 | number | 是 | 钱包数据ID |
| money | 10 | number | 是 | 转入的金额 |

**认证方式**

> 继承父级

**响应示例**

* 成功(200)

```javascript
{
	"code": 200,
	"msg": "转入成功",
	"data": []
}
```

| 参数名 | 示例值 | 参数类型 | 参数描述 |
| --- | --- | ---- | ---- |
| code | 200 | number | - |
| msg | ok | string | - |
| data | - | object | - |
| data.balance | 0.00 | string | 余额 |

* 失败(200)

```javascript
{
	"code": 0,
	"msg": "商户密钥错误"
}
```

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE3Mzo2NTUzNS9tL3VzZXIvbG9naW4iLCJpYXQiOjE3MjQ4MTkyMjcsImV4cCI6MTcyNzQxMTIyNywibmJmIjoxNzI0ODE5MjI3LCJqdGkiOiI1OFVWQlNXMXpZU3lUS0JOIiwic3ViIjoiNjU2IiwicHJ2IjoiODY2NWFlOTc3NWNmMjZmNmI4ZTQ5NmY4NmZhNTM2ZDY4ZGQ3MTgxOCJ9.utQQomZB2RjePNsy7Zz5TmYawmHkCeVD0aOKNe30Zsc | string | 是 | - |
| lang | CN | string | 是 | - |

**Query**

#### 手动转出

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-04-13 11:11:31

> 更新时间: 2025-04-13 11:11:31

```text
暂无描述
```

**接口状态**

> 已完成

**接口URL**

> http://45.200.16.18:65535/api/game/withdrawal

**请求方式**

> POST

**Content-Type**

> json

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE3Mzo2NTUzNS9tL3VzZXIvbG9naW4iLCJpYXQiOjE3MjQ4MTkyMjcsImV4cCI6MTcyNzQxMTIyNywibmJmIjoxNzI0ODE5MjI3LCJqdGkiOiI1OFVWQlNXMXpZU3lUS0JOIiwic3ViIjoiNjU2IiwicHJ2IjoiODY2NWFlOTc3NWNmMjZmNmI4ZTQ5NmY4NmZhNTM2ZDY4ZGQ3MTgxOCJ9.utQQomZB2RjePNsy7Zz5TmYawmHkCeVD0aOKNe30Zsc | string | 是 | - |
| lang | CN | string | 是 | - |

**请求Body参数**

```javascript
{
    "id": 41,
    "money": 20
}
```

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| id | 36 | number | 是 | 钱包数据ID |
| money | 10 | number | 是 | 转出的金额 |

**认证方式**

> 继承父级

**响应示例**

* 成功(200)

```javascript
{
	"code": 200,
	"msg": "转出成功",
	"data": []
}
```

| 参数名 | 示例值 | 参数类型 | 参数描述 |
| --- | --- | ---- | ---- |
| code | 200 | number | - |
| msg | ok | string | - |
| data | - | object | - |
| data.balance | 0.00 | string | 余额 |

* 失败(200)

```javascript
{
	"code": 0,
	"msg": "商户密钥错误"
}
```

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE3Mzo2NTUzNS9tL3VzZXIvbG9naW4iLCJpYXQiOjE3MjQ4MTkyMjcsImV4cCI6MTcyNzQxMTIyNywibmJmIjoxNzI0ODE5MjI3LCJqdGkiOiI1OFVWQlNXMXpZU3lUS0JOIiwic3ViIjoiNjU2IiwicHJ2IjoiODY2NWFlOTc3NWNmMjZmNmI4ZTQ5NmY4NmZhNTM2ZDY4ZGQ3MTgxOCJ9.utQQomZB2RjePNsy7Zz5TmYawmHkCeVD0aOKNe30Zsc | string | 是 | - |
| lang | CN | string | 是 | - |

**Query**

#### 手动/免转切换

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-04-13 11:11:31

> 更新时间: 2025-10-06 19:26:38

```text
暂无描述
```

**接口状态**

> 已完成

**接口URL**

> http://45.200.16.18:60000/api/game/transfer

**请求方式**

> POST

**Content-Type**

> json

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE3Mzo2NTUzNS9tL3VzZXIvbG9naW4iLCJpYXQiOjE3MjQ4MTkyMjcsImV4cCI6MTcyNzQxMTIyNywibmJmIjoxNzI0ODE5MjI3LCJqdGkiOiI1OFVWQlNXMXpZU3lUS0JOIiwic3ViIjoiNjU2IiwicHJ2IjoiODY2NWFlOTc3NWNmMjZmNmI4ZTQ5NmY4NmZhNTM2ZDY4ZGQ3MTgxOCJ9.utQQomZB2RjePNsy7Zz5TmYawmHkCeVD0aOKNe30Zsc | string | 是 | - |
| lang | CN | string | 是 | - |

**请求Body参数**

```javascript
{
    "type": 2
}
```

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| type | 2 | number | 是 | 转账模式：1手动，2免转 |

**认证方式**

> 继承父级

**响应示例**

* 成功(200)

```javascript
{
	"code": 200,
	"msg": "切换成功",
	"data": []
}
```

| 参数名 | 示例值 | 参数类型 | 参数描述 |
| --- | --- | ---- | ---- |
| code | 200 | number | - |
| msg | ok | string | - |
| data | - | object | - |
| data.balance | 0.00 | string | 余额 |

* 失败(200)

```javascript
{
	"code": 0,
	"msg": "请先将余额一键回收"
}
```

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE3Mzo2NTUzNS9tL3VzZXIvbG9naW4iLCJpYXQiOjE3MjQ4MTkyMjcsImV4cCI6MTcyNzQxMTIyNywibmJmIjoxNzI0ODE5MjI3LCJqdGkiOiI1OFVWQlNXMXpZU3lUS0JOIiwic3ViIjoiNjU2IiwicHJ2IjoiODY2NWFlOTc3NWNmMjZmNmI4ZTQ5NmY4NmZhNTM2ZDY4ZGQ3MTgxOCJ9.utQQomZB2RjePNsy7Zz5TmYawmHkCeVD0aOKNe30Zsc | string | 是 | - |
| lang | CN | string | 是 | - |

**Query**

#### 电子棋牌启动游戏

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-04-13 11:11:31

> 更新时间: 2026-03-12 23:50:30

```text
暂无描述
```

**接口状态**

> 已完成

**接口URL**

> http://45.200.16.18:60000/api/game_code/login

**请求方式**

> POST

**Content-Type**

> json

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjYwMDAwL2FwaS91c2VyL2xvZ2luIiwiaWF0IjoxNzQ0OTU0NDUxLCJleHAiOjE3NDc1NDY0NTEsIm5iZiI6MTc0NDk1NDQ1MSwianRpIjoiekRqeUVJcTdWekFVeUg3eSIsInN1YiI6IjY2MiIsInBydiI6Ijg2NjVhZTk3NzVjZjI2ZjZiOGU0OTZmODZmYTUzNmQ2OGRkNzE4MTgifQ.voqBDF4tzDa54A_hdLPTAVQqKxBNsU-AuHRRe1Mr3uQ | string | 是 | - |
| lang | CN | string | 是 | - |

**请求Body参数**

```javascript
{
    "id": 1,
    "mobile": 0
}
```

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| id | 36 | number | 是 | 首页游戏数据ID |
| mobile | 1 | number | 否 | 终端：0pc，1 wap，默认 0 |

**认证方式**

> 继承父级

**响应示例**

* 成功(200)

```javascript
{
	"code": 200,
	"msg": "ok",
	"data": {
		"url": "https://gci.msgm23.com/forwardGame.do?params=gxStRoyOs1GV4UlOckpd36O+0OKx46g+6c7yYOw7j/7Hmm/xjt/kavL2Xlg5NxbVub2cwYulfqzW2fg9iKNlpohb+/3zxlaiKk8EBb43/RiKkJMYowRGXCF/n7SyWuMGYO1CdrbwovcOXawn77ZYBqHg1whNwZm9jwTVogDUNQ3zL/EFnkcGc8ZcI8NBJcMMbtZJMm92isEhIGIKrpUWnObEPe9sQR13kAOaOIcGQ15M6fDO7U8GsQ==&key=aae5b0acabeda7120ccaf50580d487d0"
	}
}
```

| 参数名 | 示例值 | 参数类型 | 参数描述 |
| --- | --- | ---- | ---- |
| code | 200 | number | - |
| msg | ok | string | - |
| data | - | object | - |
| data.url | https://gci.msgm23.com/forwardGame.do?params=gxStRoyOs1GV4UlOckpd36O+0OKx46g+6c7yYOw7j/7Hmm/xjt/kavL2Xlg5NxbVub2cwYulfqzW2fg9iKNlpohb+/3zxlaiKk8EBb43/RiKkJMYowRGXCF/n7SyWuMGYO1CdrbwovcOXawn77ZYBqHg1whNwZm9jwTVogDUNQ3zL/EFnkcGc8ZcI8NBJcMMbtZJMm92isEhIGIKrpUWnObEPe9sQR13kAOaOIcGQ15M6fDO7U8GsQ==&key=aae5b0acabeda7120ccaf50580d487d0 | string | 游戏URL |

* 失败(200)

```javascript
{
	"code": 0,
	"msg": "商户密钥错误"
}
```

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjYwMDAwL2FwaS91c2VyL2xvZ2luIiwiaWF0IjoxNzQ0OTU0NDUxLCJleHAiOjE3NDc1NDY0NTEsIm5iZiI6MTc0NDk1NDQ1MSwianRpIjoiekRqeUVJcTdWekFVeUg3eSIsInN1YiI6IjY2MiIsInBydiI6Ijg2NjVhZTk3NzVjZjI2ZjZiOGU0OTZmODZmYTUzNmQ2OGRkNzE4MTgifQ.voqBDF4tzDa54A_hdLPTAVQqKxBNsU-AuHRRe1Mr3uQ | string | 是 | - |
| lang | CN | string | 是 | - |

**Query**

#### 收藏主游戏接口

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-07-29 10:15:57

> 更新时间: 2025-07-29 10:16:13

```text
暂无描述
```

**接口状态**

> 已完成

**接口URL**

> http://45.200.16.18:60000/api/user_favorites/interface

**请求方式**

> POST

**Content-Type**

> json

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjYwMDAwL20vdXNlci9sb2dpbiIsImlhdCI6MTc1MzcwODIwMywiZXhwIjoxNzU2MzAwMjAzLCJuYmYiOjE3NTM3MDgyMDMsImp0aSI6IngxeGdvNkhWY2pJZmZsMEIiLCJzdWIiOiI2NjIiLCJwcnYiOiI4NjY1YWU5Nzc1Y2YyNmY2YjhlNDk2Zjg2ZmE1MzZkNjhkZDcxODE4In0.WVFWbrjtqA9_V6SmcDckWoD2eQEbdQovu8OIvniK-FQ | string | 是 | - |
| lang | CN | string | 是 | - |

**请求Body参数**

```javascript
{
    "id": 19,
    "status": 0
}
```

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| id | 19 | number | 是 | 游戏数据ID |
| status | 0 | number | 是 | 状态：1收藏，0取消收藏 |

**认证方式**

> 继承父级

**响应示例**

* 成功(200)

```javascript
{
	"code": 200,
	"msg": "取消收藏成功",
	"data": []
}
```

| 参数名 | 示例值 | 参数类型 | 参数描述 |
| --- | --- | ---- | ---- |
| code | 200 | number | - |
| msg | 取消收藏成功 | string | - |
| data | - | array | - |

* 失败(200)

```javascript
{
	"code": 401,
	"msg": "认证失败！"
}
```

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjYwMDAwL20vdXNlci9sb2dpbiIsImlhdCI6MTc1MzcwODIwMywiZXhwIjoxNzU2MzAwMjAzLCJuYmYiOjE3NTM3MDgyMDMsImp0aSI6IngxeGdvNkhWY2pJZmZsMEIiLCJzdWIiOiI2NjIiLCJwcnYiOiI4NjY1YWU5Nzc1Y2YyNmY2YjhlNDk2Zjg2ZmE1MzZkNjhkZDcxODE4In0.WVFWbrjtqA9_V6SmcDckWoD2eQEbdQovu8OIvniK-FQ | string | 是 | - |
| lang | CN | string | 是 | - |

**Query**

#### 收藏电子棋牌子游戏接口

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-07-29 10:16:30

> 更新时间: 2025-07-29 10:16:50

```text
暂无描述
```

**接口状态**

> 已完成

**接口URL**

> http://45.200.16.18:60000/api/user_favorites/game

**请求方式**

> POST

**Content-Type**

> json

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjYwMDAwL20vdXNlci9sb2dpbiIsImlhdCI6MTc1MzcwODIwMywiZXhwIjoxNzU2MzAwMjAzLCJuYmYiOjE3NTM3MDgyMDMsImp0aSI6IngxeGdvNkhWY2pJZmZsMEIiLCJzdWIiOiI2NjIiLCJwcnYiOiI4NjY1YWU5Nzc1Y2YyNmY2YjhlNDk2Zjg2ZmE1MzZkNjhkZDcxODE4In0.WVFWbrjtqA9_V6SmcDckWoD2eQEbdQovu8OIvniK-FQ | string | 是 | - |
| lang | CN | string | 是 | - |

**请求Body参数**

```javascript
{
    "id": 19,
    "status": 0
}
```

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| id | 19 | number | 是 | 游戏数据ID |
| status | 0 | number | 是 | 状态：1收藏，0取消收藏 |

**认证方式**

> 继承父级

**响应示例**

* 成功(200)

```javascript
{
	"code": 200,
	"msg": "取消收藏成功",
	"data": []
}
```

| 参数名 | 示例值 | 参数类型 | 参数描述 |
| --- | --- | ---- | ---- |
| code | 200 | number | - |
| msg | 取消收藏成功 | string | - |
| data | - | array | - |

* 失败(200)

```javascript
{
	"code": 401,
	"msg": "认证失败！"
}
```

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjYwMDAwL20vdXNlci9sb2dpbiIsImlhdCI6MTc1MzcwODIwMywiZXhwIjoxNzU2MzAwMjAzLCJuYmYiOjE3NTM3MDgyMDMsImp0aSI6IngxeGdvNkhWY2pJZmZsMEIiLCJzdWIiOiI2NjIiLCJwcnYiOiI4NjY1YWU5Nzc1Y2YyNmY2YjhlNDk2Zjg2ZmE1MzZkNjhkZDcxODE4In0.WVFWbrjtqA9_V6SmcDckWoD2eQEbdQovu8OIvniK-FQ | string | 是 | - |
| lang | CN | string | 是 | - |

**Query**

### 用户中心

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-04-13 11:11:31

> 更新时间: 2025-04-13 11:11:31

```text
暂无描述
```

**目录Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| 暂无参数 |

**目录Query参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| 暂无参数 |

**目录Body参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| 暂无参数 |

**目录认证信息**

> 继承父级

**Query**

#### 问题反馈

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-04-13 11:11:31

> 更新时间: 2025-10-15 18:06:43

```text
暂无描述
```

**目录Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| 暂无参数 |

**目录Query参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| 暂无参数 |

**目录Body参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| 暂无参数 |

**目录认证信息**

> 继承父级

**Query**

##### 我的反馈

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-04-13 11:11:31

> 更新时间: 2025-04-13 11:11:31

```text
暂无描述
```

**目录Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| 暂无参数 |

**目录Query参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| 暂无参数 |

**目录Body参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| 暂无参数 |

**目录认证信息**

> 继承父级

**Query**

###### 获取数据

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-04-13 11:11:31

> 更新时间: 2025-04-13 11:11:31

```text
暂无描述
```

**接口状态**

> 已完成

**接口URL**

> http://45.200.16.18:65535/api/feedback/getlist

**请求方式**

> POST

**Content-Type**

> json

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjY1NTM1L20vdXNlci9sb2dpbiIsImlhdCI6MTcyNjMyNDE2NiwiZXhwIjoxNzI4OTE2MTY2LCJuYmYiOjE3MjYzMjQxNjYsImp0aSI6ImpOYmxISDdmbFo4MFlxOE4iLCJzdWIiOiI2NTYiLCJwcnYiOiI4NjY1YWU5Nzc1Y2YyNmY2YjhlNDk2Zjg2ZmE1MzZkNjhkZDcxODE4In0.orZlPLpk8LDMrsTL1c-5hDBEvhVsbYhYbLFBpzaKR5s | string | 是 | - |
| lang | CN | string | 是 | - |

**请求Body参数**

```javascript
{
    "page": 1,
    "size": 10
}
```

**认证方式**

> 继承父级

**响应示例**

* 成功(200)

```javascript
{
	"code": 200,
	"msg": "success",
	"data": {
		"data": [
			{
				"id": 35,
				"title": "默认分类名称",
				"text": "fgdsafdsafads",
				"text_t": null,
				"img": "/123/456.png",
				"created_at": "2024-09-14 14:50:58",
				"updated_at": "2024-09-14 14:50:58"
			}
		],
		"current_page": 1,
		"total": 1,
		"lastPage": 1
	}
}
```

| 参数名 | 示例值 | 参数类型 | 参数描述 |
| --- | --- | ---- | ---- |
| code | 200 | number | - |
| msg | success | string | - |
| data | - | object | - |
| data.data | - | array | - |
| data.data.id | 35 | number | 数据ID |
| data.data.title | 默认分类名称 | string | 反馈类型 |
| data.data.text | fgdsafdsafads | string | 反馈内容 |
| data.data.text_t | - | null | 回复内容 |
| data.data.img | /123/456.png | string | 反馈图片 |
| data.data.created_at | 2024-09-14 14:50:58 | string | 反馈时间 |
| data.data.updated_at | 2024-09-14 14:50:58 | string | 回复时间，text_t为空时不显示该字段 |
| data.current_page | 1 | number | - |
| data.total | 1 | number | - |
| data.lastPage | 1 | number | - |

* 失败(200)

```javascript
暂无数据
```

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjY1NTM1L20vdXNlci9sb2dpbiIsImlhdCI6MTcyNjMyNDE2NiwiZXhwIjoxNzI4OTE2MTY2LCJuYmYiOjE3MjYzMjQxNjYsImp0aSI6ImpOYmxISDdmbFo4MFlxOE4iLCJzdWIiOiI2NTYiLCJwcnYiOiI4NjY1YWU5Nzc1Y2YyNmY2YjhlNDk2Zjg2ZmE1MzZkNjhkZDcxODE4In0.orZlPLpk8LDMrsTL1c-5hDBEvhVsbYhYbLFBpzaKR5s | string | 是 | - |
| lang | CN | string | 是 | - |

**Query**

##### 获取类型

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-04-13 11:11:31

> 更新时间: 2025-10-15 18:06:56

```text
暂无描述
```

**接口状态**

> 已完成

**接口URL**

> http://45.200.16.18:65535/api/feedback_type/getlist

**请求方式**

> POST

**Content-Type**

> json

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjY1NTM1L20vdXNlci9sb2dpbiIsImlhdCI6MTcyNjMyNDE2NiwiZXhwIjoxNzI4OTE2MTY2LCJuYmYiOjE3MjYzMjQxNjYsImp0aSI6ImpOYmxISDdmbFo4MFlxOE4iLCJzdWIiOiI2NTYiLCJwcnYiOiI4NjY1YWU5Nzc1Y2YyNmY2YjhlNDk2Zjg2ZmE1MzZkNjhkZDcxODE4In0.orZlPLpk8LDMrsTL1c-5hDBEvhVsbYhYbLFBpzaKR5s | string | 是 | - |
| lang | CN | string | 是 | - |

**请求Body参数**

```javascript
暂无数据
```

**认证方式**

> 继承父级

**响应示例**

* 成功(200)

```javascript
{
	"code": 200,
	"msg": "success",
	"data": [
		{
			"id": 38,
			"title": "1"
		},
		{
			"id": 37,
			"title": "123222"
		},
		{
			"id": 34,
			"title": "默认分类名称aaaaa"
		},
		{
			"id": 33,
			"title": "默认分类名称"
		}
	]
}
```

| 参数名 | 示例值 | 参数类型 | 参数描述 |
| --- | --- | ---- | ---- |
| code | 200 | number | - |
| msg | success | string | - |
| data | - | array | - |
| data.id | 38 | number | 数据ID |
| data.title | 1 | string | 类型名称 |

* 失败(200)

```javascript
暂无数据
```

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjY1NTM1L20vdXNlci9sb2dpbiIsImlhdCI6MTcyNjMyNDE2NiwiZXhwIjoxNzI4OTE2MTY2LCJuYmYiOjE3MjYzMjQxNjYsImp0aSI6ImpOYmxISDdmbFo4MFlxOE4iLCJzdWIiOiI2NTYiLCJwcnYiOiI4NjY1YWU5Nzc1Y2YyNmY2YjhlNDk2Zjg2ZmE1MzZkNjhkZDcxODE4In0.orZlPLpk8LDMrsTL1c-5hDBEvhVsbYhYbLFBpzaKR5s | string | 是 | - |
| lang | CN | string | 是 | - |

**Query**

##### 确定反馈

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-04-13 11:11:31

> 更新时间: 2025-04-13 11:11:31

```text
暂无描述
```

**接口状态**

> 已完成

**接口URL**

> http://45.200.16.18:65535/api/feedback/to

**请求方式**

> POST

**Content-Type**

> json

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjY1NTM1L20vdXNlci9sb2dpbiIsImlhdCI6MTcyNjMyNDE2NiwiZXhwIjoxNzI4OTE2MTY2LCJuYmYiOjE3MjYzMjQxNjYsImp0aSI6ImpOYmxISDdmbFo4MFlxOE4iLCJzdWIiOiI2NTYiLCJwcnYiOiI4NjY1YWU5Nzc1Y2YyNmY2YjhlNDk2Zjg2ZmE1MzZkNjhkZDcxODE4In0.orZlPLpk8LDMrsTL1c-5hDBEvhVsbYhYbLFBpzaKR5s | string | 是 | - |
| lang | CN | string | 是 | - |

**请求Body参数**

```javascript
{
    "id": 331,
    "text": "fgdsafdsafads",
    "img": "/123/456.png"

}
```

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| id | 33 | number | 是 | 内容类型ID |
| text | fgdsafdsafads | string | 是 | 反馈内容 |
| img | /123/456.png | string | 否 | 反馈图片 |

**认证方式**

> 继承父级

**响应示例**

* 成功(200)

```javascript
{
	"code": 200,
	"msg": "反馈成功",
	"data": []
}
```

| 参数名 | 示例值 | 参数类型 | 参数描述 |
| --- | --- | ---- | ---- |
| code | 200 | number | - |
| msg | 反馈成功 | string | - |
| data | - | array | - |

* 失败(200)

```javascript
{
	"code": 0,
	"msg": "类型不存在"
}
```

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjY1NTM1L20vdXNlci9sb2dpbiIsImlhdCI6MTcyNjMyNDE2NiwiZXhwIjoxNzI4OTE2MTY2LCJuYmYiOjE3MjYzMjQxNjYsImp0aSI6ImpOYmxISDdmbFo4MFlxOE4iLCJzdWIiOiI2NTYiLCJwcnYiOiI4NjY1YWU5Nzc1Y2YyNmY2YjhlNDk2Zjg2ZmE1MzZkNjhkZDcxODE4In0.orZlPLpk8LDMrsTL1c-5hDBEvhVsbYhYbLFBpzaKR5s | string | 是 | - |
| lang | CN | string | 是 | - |

**Query**

#### 我的卡包

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-04-13 11:11:31

> 更新时间: 2025-04-13 11:11:31

```text
暂无描述
```

**目录Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| 暂无参数 |

**目录Query参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| 暂无参数 |

**目录Body参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| 暂无参数 |

**目录认证信息**

> 继承父级

**Query**

##### 获取数据

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-04-13 11:11:31

> 更新时间: 2026-02-14 01:34:15

```text
暂无描述
```

**接口状态**

> 已完成

**接口URL**

> http://45.200.16.18:60000/api/drawing/getlist

**请求方式**

> POST

**Content-Type**

> none

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjYwMDAwL2FwaS91c2VyL2xvZ2luIiwiaWF0IjoxNzcxMDAzOTQ2LCJleHAiOjE3NzM1OTU5NDYsIm5iZiI6MTc3MTAwMzk0NiwianRpIjoicW5TNUdLNUZ4ZmE0dHZ5dyIsInN1YiI6IjY2MiIsInBydiI6Ijg2NjVhZTk3NzVjZjI2ZjZiOGU0OTZmODZmYTUzNmQ2OGRkNzE4MTgifQ.djRvY7T99xyBnhp8-0SO29Z87y9mX55MPTnkHBvALWU | string | 是 | - |
| lang | CN | string | 是 | - |

**认证方式**

> 继承父级

**响应示例**

* 成功(200)

```javascript
{
	"code": 200,
	"msg": "success",
	"data": [
		{
			"id": 20,
			"card": "2355566666677",
			"img": "https://apis.xh-demo.com/uploads/images/yhlb//1664cb68ea56fc120e89e379fc2f490e.png",
			"qrcode": null,
			"alias": "测试",
			"title": "USDT-ERC20",
			"rete": 6.9185
		}
	]
}
```

| 参数名 | 示例值 | 参数类型 | 参数描述 |
| --- | --- | ---- | ---- |
| code | 200 | number | - |
| msg | success | string | - |
| data | - | array | - |
| data.id | 20 | number | - |
| data.card | 2355566666677 | string | - |
| data.img | - | Null | - |
| data.type | 2 | number | 类型：1银行卡，2虚拟币，3支付宝 |
| data.title | USDT-ERC20 | string | - |
| data.qrcode | - | string | 二维码 |

* 失败(200)

```javascript
暂无数据
```

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjYwMDAwL2FwaS91c2VyL2xvZ2luIiwiaWF0IjoxNzcxMDAzOTQ2LCJleHAiOjE3NzM1OTU5NDYsIm5iZiI6MTc3MTAwMzk0NiwianRpIjoicW5TNUdLNUZ4ZmE0dHZ5dyIsInN1YiI6IjY2MiIsInBydiI6Ijg2NjVhZTk3NzVjZjI2ZjZiOGU0OTZmODZmYTUzNmQ2OGRkNzE4MTgifQ.djRvY7T99xyBnhp8-0SO29Z87y9mX55MPTnkHBvALWU | string | 是 | - |
| lang | CN | string | 是 | - |

**Query**

##### 删除卡片

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-04-13 11:11:32

> 更新时间: 2025-04-13 11:11:32

```text
暂无描述
```

**接口状态**

> 已完成

**接口URL**

> http://45.200.16.18:65535/api/member_bank/delete

**请求方式**

> POST

**Content-Type**

> json

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE3Mzo2NTUzNS9tL3VzZXIvbG9naW4iLCJpYXQiOjE3MjQ4MTkyMjcsImV4cCI6MTcyNzQxMTIyNywibmJmIjoxNzI0ODE5MjI3LCJqdGkiOiI1OFVWQlNXMXpZU3lUS0JOIiwic3ViIjoiNjU2IiwicHJ2IjoiODY2NWFlOTc3NWNmMjZmNmI4ZTQ5NmY4NmZhNTM2ZDY4ZGQ3MTgxOCJ9.utQQomZB2RjePNsy7Zz5TmYawmHkCeVD0aOKNe30Zsc | string | 是 | - |
| lang | CN | string | 是 | - |

**请求Body参数**

```javascript
{
    "id": 10
}
```

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| id | 10 | number | 是 | 数据ID |

**认证方式**

> 继承父级

**响应示例**

* 成功(200)

```javascript
{
	"code": 200,
	"msg": "删除成功",
	"data": []
}
```

| 参数名 | 示例值 | 参数类型 | 参数描述 |
| --- | --- | ---- | ---- |
| code | 200 | number | - |
| msg | 删除成功 | string | - |
| data | - | array | - |

* 失败(200)

```javascript
暂无数据
```

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE3Mzo2NTUzNS9tL3VzZXIvbG9naW4iLCJpYXQiOjE3MjQ4MTkyMjcsImV4cCI6MTcyNzQxMTIyNywibmJmIjoxNzI0ODE5MjI3LCJqdGkiOiI1OFVWQlNXMXpZU3lUS0JOIiwic3ViIjoiNjU2IiwicHJ2IjoiODY2NWFlOTc3NWNmMjZmNmI4ZTQ5NmY4NmZhNTM2ZDY4ZGQ3MTgxOCJ9.utQQomZB2RjePNsy7Zz5TmYawmHkCeVD0aOKNe30Zsc | string | 是 | - |
| lang | CN | string | 是 | - |

**Query**

##### 绑卡-获取支持的卡片类型

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-04-13 11:11:32

> 更新时间: 2025-12-11 15:22:27

```text
暂无描述
```

**接口状态**

> 已完成

**接口URL**

> http://45.200.16.18:60000/api/bank/getlist

**请求方式**

> POST

**Content-Type**

> json

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjYwMDAwL2FwaS91c2VyL3JlZ2lzdGVyIiwiaWF0IjoxNzY1NDM3MDU4LCJleHAiOjE3NjgwMjkwNTgsIm5iZiI6MTc2NTQzNzA1OCwianRpIjoibkFqVVZUVUhWaFVHT3R1MCIsInN1YiI6Ijc0MSIsInBydiI6Ijg2NjVhZTk3NzVjZjI2ZjZiOGU0OTZmODZmYTUzNmQ2OGRkNzE4MTgifQ.kvxspraCKt1FlqsibeJA04Oz8MLTfbmhLqalVNKOQkw | string | 是 | - |
| lang | CN | string | 是 | - |

**请求Body参数**

```javascript
{
    "type": 3
}
```

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| type | 1 | number | 是 | 类型：1银行卡，2虚拟币，3支付宝 |

**认证方式**

> 继承父级

**响应示例**

* 成功(200)

```javascript
{
	"code": 200,
	"msg": "success",
	"data": [
		{
			"id": 5,
			"img": null,
			"type": 1,
			"title": "微信支付"
		},
		{
			"id": 6,
			"img": null,
			"type": 2,
			"title": "微信支付"
		}
	]
}
```

| 参数名 | 示例值 | 参数类型 | 参数描述 |
| --- | --- | ---- | ---- |
| code | 200 | number | - |
| msg | success | string | - |
| data | - | array | - |
| data.id | 5 | number | 数据ID |
| data.img | - | Null | 图标 |
| data.type | 1 | number | 类型：1银行卡，2虚拟币，虚拟币只需上传收款地址即可 |
| data.title | 微信支付 | string | 类型名称 |

* 失败(200)

```javascript
暂无数据
```

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjYwMDAwL2FwaS91c2VyL3JlZ2lzdGVyIiwiaWF0IjoxNzY1NDM3MDU4LCJleHAiOjE3NjgwMjkwNTgsIm5iZiI6MTc2NTQzNzA1OCwianRpIjoibkFqVVZUVUhWaFVHT3R1MCIsInN1YiI6Ijc0MSIsInBydiI6Ijg2NjVhZTk3NzVjZjI2ZjZiOGU0OTZmODZmYTUzNmQ2OGRkNzE4MTgifQ.kvxspraCKt1FlqsibeJA04Oz8MLTfbmhLqalVNKOQkw | string | 是 | - |
| lang | CN | string | 是 | - |

**Query**

##### 确定绑卡

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-04-13 11:11:32

> 更新时间: 2026-02-11 12:57:29

```text
暂无描述
```

**接口状态**

> 已完成

**接口URL**

> http://45.200.16.18:60000/api/member_bank/binding

**请求方式**

> POST

**Content-Type**

> json

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjYwMDAwL2FwaS91c2VyL3JlZ2lzdGVyIiwiaWF0IjoxNzY1NDM3MDU4LCJleHAiOjE3NjgwMjkwNTgsIm5iZiI6MTc2NTQzNzA1OCwianRpIjoibkFqVVZUVUhWaFVHT3R1MCIsInN1YiI6Ijc0MSIsInBydiI6Ijg2NjVhZTk3NzVjZjI2ZjZiOGU0OTZmODZmYTUzNmQ2OGRkNzE4MTgifQ.kvxspraCKt1FlqsibeJA04Oz8MLTfbmhLqalVNKOQkw | string | 是 | - |
| lang | CN | string | 是 | - |

**请求Body参数**

```javascript
{
    "id": 9,
    "card": 123156456456456,
    "addres": "广泛大概多少分功夫大师功夫大师",
    "alias": "423432",
    "img": ""


}
```

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| id | 6 | number | 是 | 数据ID |
| card | 123156456456456 | number | 是 | 卡号 |
| addres | 广泛大概多少分功夫大师功夫大师 | string | 是 | 开户地，虚拟币只需卡号即可 |
| alias | 423432 | string | 否 | 别名 |
| img | - | string | 否 | 二维码 |

**认证方式**

> 继承父级

**响应示例**

* 成功(200)

```javascript
{
	"code": 200,
	"msg": "绑定成功",
	"data": []
}
```

| 参数名 | 示例值 | 参数类型 | 参数描述 |
| --- | --- | ---- | ---- |
| code | 200 | number | - |
| msg | 绑定成功 | string | - |
| data | - | array | - |

* 失败(200)

```javascript
暂无数据
```

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjYwMDAwL2FwaS91c2VyL3JlZ2lzdGVyIiwiaWF0IjoxNzY1NDM3MDU4LCJleHAiOjE3NjgwMjkwNTgsIm5iZiI6MTc2NTQzNzA1OCwianRpIjoibkFqVVZUVUhWaFVHT3R1MCIsInN1YiI6Ijc0MSIsInBydiI6Ijg2NjVhZTk3NzVjZjI2ZjZiOGU0OTZmODZmYTUzNmQ2OGRkNzE4MTgifQ.kvxspraCKt1FlqsibeJA04Oz8MLTfbmhLqalVNKOQkw | string | 是 | - |
| lang | CN | string | 是 | - |

**Query**

#### VIP权益

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-04-13 11:11:31

> 更新时间: 2025-04-13 11:11:31

```text
暂无描述
```

**目录Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| 暂无参数 |

**目录Query参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| 暂无参数 |

**目录Body参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| 暂无参数 |

**目录认证信息**

> 继承父级

**Query**

##### 获取数据

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-04-13 11:11:32

> 更新时间: 2025-12-21 15:05:48

```text
暂无描述
```

**接口状态**

> 已完成

**接口URL**

> http://45.200.16.18:60000/api/vip/getlist

**请求方式**

> POST

**Content-Type**

> none

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjY1NTM1L2FwaS91c2VyL2xvZ2luIiwiaWF0IjoxNzI3OTc1NDkzLCJleHAiOjE3MzA1Njc0OTMsIm5iZiI6MTcyNzk3NTQ5MywianRpIjoiT2o5RkNBMmxyN29HZ21IciIsInN1YiI6IjY1NiIsInBydiI6Ijg2NjVhZTk3NzVjZjI2ZjZiOGU0OTZmODZmYTUzNmQ2OGRkNzE4MTgifQ.w6Y1FXuGwORBkAwKjqEfW0VQACKj6bKN-FI9mGozkVE | string | 是 | - |
| lang | CN | string | 是 | - |

**认证方式**

> 继承父级

**响应示例**

* 成功(200)

```javascript
{
	"code": 200,
	"msg": "success",
	"data": [
		{
			"id": 28,
			"charge_level": "111.00",
			"flowing_level": "2.00",
			"min_drawing": "3.00",
			"day_count_drawing": 4,
			"day_amount_drawing": "5.00",
			"min_recharge": "6.00",
			"max_recharge": "7.00",
			"level_give": "8.00",
			"birthday_give": "9.00",
			"week_red": "0.00",
			"min_transfer": "10.00",
			"title": "VIP10",
			"live_bl": "3.00",
			"games_bl": "4.00",
			"lottery_bl": "5.00",
			"sport_bl": "6.00",
			"gaming_bl": "7.00",
			"fishing_bl": "8.00",
			"poker_bl": "9.00"
		},
		{
			"id": 27,
			"charge_level": "1.00",
			"flowing_level": "2.00",
			"min_drawing": "3.00",
			"day_count_drawing": 4,
			"day_amount_drawing": "5.00",
			"min_recharge": "6.00",
			"max_recharge": "7.00",
			"level_give": "8.00",
			"birthday_give": "9.00",
			"week_red": "0.00",
			"min_transfer": "11.00",
			"title": "VIP9",
			"live_bl": "3.00",
			"games_bl": "4.00",
			"lottery_bl": "5.00",
			"sport_bl": "6.00",
			"gaming_bl": "7.00",
			"fishing_bl": "8.00",
			"poker_bl": "10.00"
		},
		{
			"id": 26,
			"charge_level": "0.00",
			"flowing_level": "0.00",
			"min_drawing": "0.00",
			"day_count_drawing": 0,
			"day_amount_drawing": "0.00",
			"min_recharge": "0.00",
			"max_recharge": "0.00",
			"level_give": "0.00",
			"birthday_give": "0.00",
			"week_red": "0.00",
			"min_transfer": "0.00",
			"title": "VIP8",
			"live_bl": "0.00",
			"games_bl": "0.00",
			"lottery_bl": "0.00",
			"sport_bl": "0.00",
			"gaming_bl": "0.00",
			"fishing_bl": "0.00",
			"poker_bl": "0.00"
		},
		{
			"id": 25,
			"charge_level": "0.00",
			"flowing_level": "0.00",
			"min_drawing": "0.00",
			"day_count_drawing": 0,
			"day_amount_drawing": "0.00",
			"min_recharge": "0.00",
			"max_recharge": "0.00",
			"level_give": "0.00",
			"birthday_give": "0.00",
			"week_red": "0.00",
			"min_transfer": "0.00",
			"title": "VIP7",
			"live_bl": "0.00",
			"games_bl": "0.00",
			"lottery_bl": "0.00",
			"sport_bl": "0.00",
			"gaming_bl": "0.00",
			"fishing_bl": "0.00",
			"poker_bl": "0.00"
		},
		{
			"id": 24,
			"charge_level": "0.00",
			"flowing_level": "0.00",
			"min_drawing": "0.00",
			"day_count_drawing": 0,
			"day_amount_drawing": "0.00",
			"min_recharge": "0.00",
			"max_recharge": "0.00",
			"level_give": "0.00",
			"birthday_give": "0.00",
			"week_red": "0.00",
			"min_transfer": "0.00",
			"title": "VIP6",
			"live_bl": "0.00",
			"games_bl": "0.00",
			"lottery_bl": "0.00",
			"sport_bl": "0.00",
			"gaming_bl": "0.00",
			"fishing_bl": "0.00",
			"poker_bl": "0.00"
		},
		{
			"id": 23,
			"charge_level": "0.00",
			"flowing_level": "0.00",
			"min_drawing": "0.00",
			"day_count_drawing": 0,
			"day_amount_drawing": "0.00",
			"min_recharge": "0.00",
			"max_recharge": "0.00",
			"level_give": "0.00",
			"birthday_give": "0.00",
			"week_red": "0.00",
			"min_transfer": "0.00",
			"title": "VIP5",
			"live_bl": "0.00",
			"games_bl": "0.00",
			"lottery_bl": "0.00",
			"sport_bl": "0.00",
			"gaming_bl": "0.00",
			"fishing_bl": "0.00",
			"poker_bl": "0.00"
		},
		{
			"id": 22,
			"charge_level": "0.00",
			"flowing_level": "0.00",
			"min_drawing": "0.00",
			"day_count_drawing": 0,
			"day_amount_drawing": "0.00",
			"min_recharge": "0.00",
			"max_recharge": "0.00",
			"level_give": "0.00",
			"birthday_give": "0.00",
			"week_red": "0.00",
			"min_transfer": "0.00",
			"title": "VIP4",
			"live_bl": "0.00",
			"games_bl": "0.00",
			"lottery_bl": "0.00",
			"sport_bl": "0.00",
			"gaming_bl": "0.00",
			"fishing_bl": "0.00",
			"poker_bl": "0.00"
		},
		{
			"id": 21,
			"charge_level": "0.00",
			"flowing_level": "0.00",
			"min_drawing": "0.00",
			"day_count_drawing": 0,
			"day_amount_drawing": "0.00",
			"min_recharge": "0.00",
			"max_recharge": "0.00",
			"level_give": "0.00",
			"birthday_give": "0.00",
			"week_red": "0.00",
			"min_transfer": "0.00",
			"title": "VIP3",
			"live_bl": "0.00",
			"games_bl": "0.00",
			"lottery_bl": "0.00",
			"sport_bl": "0.00",
			"gaming_bl": "0.00",
			"fishing_bl": "0.00",
			"poker_bl": "0.00"
		},
		{
			"id": 20,
			"charge_level": "0.00",
			"flowing_level": "0.00",
			"min_drawing": "0.00",
			"day_count_drawing": 0,
			"day_amount_drawing": "0.00",
			"min_recharge": "0.00",
			"max_recharge": "0.00",
			"level_give": "0.00",
			"birthday_give": "0.00",
			"week_red": "0.00",
			"min_transfer": "0.00",
			"title": "VIP2",
			"live_bl": "0.00",
			"games_bl": "0.00",
			"lottery_bl": "0.00",
			"sport_bl": "0.00",
			"gaming_bl": "0.00",
			"fishing_bl": "0.00",
			"poker_bl": "0.00"
		},
		{
			"id": 19,
			"charge_level": "122.00",
			"flowing_level": "2.00",
			"min_drawing": "3.00",
			"day_count_drawing": 4,
			"day_amount_drawing": "5.00",
			"min_recharge": "6.00",
			"max_recharge": "7.00",
			"level_give": "8.00",
			"birthday_give": "9.00",
			"week_red": "0.00",
			"min_transfer": "10.00",
			"title": "VIP1",
			"live_bl": "0.00",
			"games_bl": "0.00",
			"lottery_bl": "0.00",
			"sport_bl": "0.00",
			"gaming_bl": "0.00",
			"fishing_bl": "0.00",
			"poker_bl": "0.00"
		}
	],
		"total_bet": 0,
		"total_deposit": 0	
}
```

| 参数名 | 示例值 | 参数类型 | 参数描述 |
| --- | --- | ---- | ---- |
| code | 200 | number | - |
| msg | success | string | - |
| data | - | array | - |
| data.id | 28 | number | 数据ID |
| data.charge_level | 111.00 | string | 升级存款 |
| data.flowing_level | 2.00 | string | 会员升级流水 |
| data.min_drawing | 3.00 | string | 最低提现金额 |
| data.day_count_drawing | 4 | number | 单日提现次数 |
| data.day_amount_drawing | 5.00 | string | 单日提现总金额限额 |
| data.min_recharge | 6.00 | string | 单笔最低充值金额 |
| data.max_recharge | 7.00 | string | 单笔最高充值金额 |
| data.level_give | 8.00 | string | 升级赠送金额 |
| data.birthday_give | 9.00 | string | 生日赠送 |
| data.week_red | 0.00 | string | 周红包 |
| data.min_transfer | 10.00 | string | 最低转账金额 |
| data.title | VIP10 | string | VIP名称 |
| data.live_bl | 3.00 | string | 视讯反水 |
| data.games_bl | 4.00 | string | 电子反水 |
| data.lottery_bl | 5.00 | string | 彩票反水 |
| data.sport_bl | 6.00 | string | 体育反水 |
| data.gaming_bl | 7.00 | string | 电竞反水 |
| data.fishing_bl | 8.00 | string | 捕鱼反水 |
| data.poker_bl | 9.00 | string | 棋牌反水 |

* 失败(200)

```javascript
暂无数据
```

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjY1NTM1L2FwaS91c2VyL2xvZ2luIiwiaWF0IjoxNzI3OTc1NDkzLCJleHAiOjE3MzA1Njc0OTMsIm5iZiI6MTcyNzk3NTQ5MywianRpIjoiT2o5RkNBMmxyN29HZ21IciIsInN1YiI6IjY1NiIsInBydiI6Ijg2NjVhZTk3NzVjZjI2ZjZiOGU0OTZmODZmYTUzNmQ2OGRkNzE4MTgifQ.w6Y1FXuGwORBkAwKjqEfW0VQACKj6bKN-FI9mGozkVE | string | 是 | - |
| lang | CN | string | 是 | - |

**Query**

#### 会员资料

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-04-13 11:11:31

> 更新时间: 2025-10-15 18:08:31

```text
暂无描述
```

**目录Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| 暂无参数 |

**目录Query参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| 暂无参数 |

**目录Body参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| 暂无参数 |

**目录认证信息**

> 继承父级

**Query**

##### 修改个人信息

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-04-13 11:11:32

> 更新时间: 2026-02-06 14:29:12

```text
暂无描述
```

**接口状态**

> 已完成

**接口URL**

> http://45.200.16.18:65535/api/user/edit

**请求方式**

> POST

**Content-Type**

> json

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjY1NTM1L20vdXNlci9sb2dpbiIsImlhdCI6MTcyNzExNDUzOCwiZXhwIjoxNzI5NzA2NTM4LCJuYmYiOjE3MjcxMTQ1MzgsImp0aSI6IkVGM3lRUEVrajBOQWpqeWciLCJzdWIiOiI2NTYiLCJwcnYiOiI4NjY1YWU5Nzc1Y2YyNmY2YjhlNDk2Zjg2ZmE1MzZkNjhkZDcxODE4In0.Y88wrGuvmj-OJQ8rTo3clxPyukk9rSGSF76uF0Byh14 | string | 是 | - |
| lang | CN | string | 是 | - |

**请求Body参数**

```javascript
{
    "img": "fdsfdsfds",
    "telegram": "dsadas",
    "real_name": 123,
    "area_code": "+86",
    "phone": 13145678961,
    "gender": "男",
    "born_time": "2004-05-06",
    "qq": 456456,
    "email": "123456@163.com"
}
```

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| img | fdsfdsfds | string | 否 | 头像 |
| real_name | 123 | number | 否 | 真实姓名 |
| phone | 13145678961 | number | 否 | 手机号 |
| gender | 男 | string | 否 | 性别 |
| born_time | 2004-05-06 | string | 否 | 出生日期 |
| qq | 456456 | number | 否 | QQ号 |
| email | 123456@163.com | string | 否 | 邮箱 |

**认证方式**

> 继承父级

**响应示例**

* 成功(200)

```javascript
暂无数据
```

* 失败(404)

```javascript
暂无数据
```

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjY1NTM1L20vdXNlci9sb2dpbiIsImlhdCI6MTcyNzExNDUzOCwiZXhwIjoxNzI5NzA2NTM4LCJuYmYiOjE3MjcxMTQ1MzgsImp0aSI6IkVGM3lRUEVrajBOQWpqeWciLCJzdWIiOiI2NTYiLCJwcnYiOiI4NjY1YWU5Nzc1Y2YyNmY2YjhlNDk2Zjg2ZmE1MzZkNjhkZDcxODE4In0.Y88wrGuvmj-OJQ8rTo3clxPyukk9rSGSF76uF0Byh14 | string | 是 | - |
| lang | CN | string | 是 | - |

**Query**

#### 站内通知

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-04-13 11:11:31

> 更新时间: 2025-04-13 11:11:31

```text
暂无描述
```

**目录Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| 暂无参数 |

**目录Query参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| 暂无参数 |

**目录Body参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| 暂无参数 |

**目录认证信息**

> 继承父级

**Query**

##### 获取数据

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-04-13 11:11:32

> 更新时间: 2025-10-06 19:31:36

```text
暂无描述
```

**接口状态**

> 已完成

**接口URL**

> http://45.200.16.18:60000/api/notify/getlist

**请求方式**

> POST

**Content-Type**

> json

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjY1NTM1L20vdXNlci9sb2dpbiIsImlhdCI6MTcyNzExNDUzOCwiZXhwIjoxNzI5NzA2NTM4LCJuYmYiOjE3MjcxMTQ1MzgsImp0aSI6IkVGM3lRUEVrajBOQWpqeWciLCJzdWIiOiI2NTYiLCJwcnYiOiI4NjY1YWU5Nzc1Y2YyNmY2YjhlNDk2Zjg2ZmE1MzZkNjhkZDcxODE4In0.Y88wrGuvmj-OJQ8rTo3clxPyukk9rSGSF76uF0Byh14 | string | 是 | - |
| lang | CN | string | 是 | - |

**请求Body参数**

```javascript
{
    "page": 1,
    "size": 10
}
```

**认证方式**

> 继承父级

**响应示例**

* 成功(200)

```javascript
{
	"code": 200,
	"msg": "success",
	"data": {
		"data": [
			{
				"id": 1337,
				"title": "43",
				"text": "45454",
				"type": 1,
				"created_at": "2024-08-27 05:35:18"
			}
		],
		"current_page": 1,
		"total": 1,
		"lastPage": 1
	}
}
```

| 参数名 | 示例值 | 参数类型 | 参数描述 |
| --- | --- | ---- | ---- |
| code | 200 | number | - |
| msg | success | string | - |
| data | - | object | - |
| data.data | - | array | - |
| data.data.id | 1337 | number | 数据ID |
| data.data.title | 43 | string | 消息标题 |
| data.data.text | 45454 | string | 内容消息 |
| data.data.type | 1 | number | 类型：1未读，2已读 |
| data.data.created_at | 2024-08-27 05:35:18 | string | 时间 |
| data.current_page | 1 | number | - |
| data.total | 1 | number | - |
| data.lastPage | 1 | number | - |

* 失败(200)

```javascript
暂无数据
```

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjY1NTM1L20vdXNlci9sb2dpbiIsImlhdCI6MTcyNzExNDUzOCwiZXhwIjoxNzI5NzA2NTM4LCJuYmYiOjE3MjcxMTQ1MzgsImp0aSI6IkVGM3lRUEVrajBOQWpqeWciLCJzdWIiOiI2NTYiLCJwcnYiOiI4NjY1YWU5Nzc1Y2YyNmY2YjhlNDk2Zjg2ZmE1MzZkNjhkZDcxODE4In0.Y88wrGuvmj-OJQ8rTo3clxPyukk9rSGSF76uF0Byh14 | string | 是 | - |
| lang | CN | string | 是 | - |

**Query**

##### 无感修改为已读状态

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-04-13 11:11:32

> 更新时间: 2025-04-13 11:11:32

```text
暂无描述
```

**接口状态**

> 已完成

**接口URL**

> http://45.200.16.18:65535/api/notify/status

**请求方式**

> POST

**Content-Type**

> json

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjY1NTM1L20vdXNlci9sb2dpbiIsImlhdCI6MTcyNzExNDUzOCwiZXhwIjoxNzI5NzA2NTM4LCJuYmYiOjE3MjcxMTQ1MzgsImp0aSI6IkVGM3lRUEVrajBOQWpqeWciLCJzdWIiOiI2NTYiLCJwcnYiOiI4NjY1YWU5Nzc1Y2YyNmY2YjhlNDk2Zjg2ZmE1MzZkNjhkZDcxODE4In0.Y88wrGuvmj-OJQ8rTo3clxPyukk9rSGSF76uF0Byh14 | string | 是 | - |
| lang | CN | string | 是 | - |

**请求Body参数**

```javascript
{
    "id": 1350
}
```

**认证方式**

> 继承父级

**响应示例**

* 成功(200)

```javascript
{
	"code": 200,
	"msg": "ok",
	"data": []
}
```

| 参数名 | 示例值 | 参数类型 | 参数描述 |
| --- | --- | ---- | ---- |
| code | 200 | number | - |
| msg | ok | string | - |
| data | - | array | - |

* 失败(200)

```javascript
暂无数据
```

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjY1NTM1L20vdXNlci9sb2dpbiIsImlhdCI6MTcyNzExNDUzOCwiZXhwIjoxNzI5NzA2NTM4LCJuYmYiOjE3MjcxMTQ1MzgsImp0aSI6IkVGM3lRUEVrajBOQWpqeWciLCJzdWIiOiI2NTYiLCJwcnYiOiI4NjY1YWU5Nzc1Y2YyNmY2YjhlNDk2Zjg2ZmE1MzZkNjhkZDcxODE4In0.Y88wrGuvmj-OJQ8rTo3clxPyukk9rSGSF76uF0Byh14 | string | 是 | - |
| lang | CN | string | 是 | - |

**Query**

#### 记录

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-10-15 17:58:42

> 更新时间: 2025-10-15 18:01:01

**记录**

**目录Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| 暂无参数 |

**目录Query参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| 暂无参数 |

**目录Body参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| 暂无参数 |

**目录认证信息**

> 继承父级

**Query**

##### 充值提现记录

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-04-13 11:11:31

> 更新时间: 2025-10-15 18:03:21

```text
暂无描述
```

**目录Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| 暂无参数 |

**目录Query参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| 暂无参数 |

**目录Body参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| 暂无参数 |

**目录认证信息**

> 继承父级

**Query**

###### 获取数据

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-04-13 11:11:31

> 更新时间: 2026-04-25 23:38:08

```text
暂无描述
```

**接口状态**

> 已完成

**接口URL**

> http://45.200.16.18:60000/api/trade/record

**请求方式**

> POST

**Content-Type**

> json

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE3Mzo2NTUzNS9tL3VzZXIvbG9naW4iLCJpYXQiOjE3MjQ4MTkyMjcsImV4cCI6MTcyNzQxMTIyNywibmJmIjoxNzI0ODE5MjI3LCJqdGkiOiI1OFVWQlNXMXpZU3lUS0JOIiwic3ViIjoiNjU2IiwicHJ2IjoiODY2NWFlOTc3NWNmMjZmNmI4ZTQ5NmY4NmZhNTM2ZDY4ZGQ3MTgxOCJ9.utQQomZB2RjePNsy7Zz5TmYawmHkCeVD0aOKNe30Zsc | string | 是 | - |
| lang | CN | string | 是 | - |

**请求Body参数**

```javascript
{
    "page": 1,
    "size": 10,
    "type": "",
    "status": 1,
    "start_date": "",
    "end_date": ""
}
```

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| page | 1 | number | 是 | - |
| size | 10 | number | 是 | - |
| type | - | string | 否 | 类型：recharge充值记录，drawing提款记录，默认充值记录 |
| status | 1 | number | 否 | 状态：1成功，0失败，5处理中 |
| start_date | 2025-12-11 | string | 否 | 开始时间 |
| end_date | 2025-12-16 | string | 否 | 结束时间 |

**认证方式**

> 继承父级

**响应示例**

* 成功(200)

```javascript
{
	"code": 200,
	"msg": "success",
	"data": {
		"data": [
			{
				"id": 35,
				"order": "202408310526281725081988",
				"title": "TOpay",
				"money": "12345.0000",
				"status": 1,
				"note": "123",
				"created_at": "2024-08-31 05:26:28"
			},
			{
				"id": 34,
				"order": "202408310501411725080501",
				"title": "微信支付",
				"money": "12345.0000",
				"status": 5,
				"note": "123",
				"created_at": "2024-08-31 05:01:41"
			}
		],
		"current_page": 1,
		"total": 2,
		"lastPage": 1
	}
}
```

| 参数名 | 示例值 | 参数类型 | 参数描述 |
| --- | --- | ---- | ---- |
| code | 200 | number | - |
| msg | success | string | - |
| data | - | object | - |
| data.data | - | array | - |
| data.data.id | 35 | number | 数据ID |
| data.data.order | 202408310526281725081988 | string | 订单号 |
| data.data.title | TOpay | string | 充值方式 |
| data.data.money | 12345.0000 | string | 充值金额 |
| data.data.status | 1 | number | 提款状态：1成功，0失败，5充值中，充值状态：1回调成功，0订单超时，5充值中，2手动确认，3 会员取消，4后台拒绝 |
| data.data.created_at | 2024-08-31 05:26:28 | string | 提交时间 |
| data.current_page | 1 | number | - |
| data.total | 2 | number | - |
| data.lastPage | 1 | number | - |
| data.data.note | 11111 | string | 描述/备注 |

* 失败(200)

```javascript
暂无数据
```

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE3Mzo2NTUzNS9tL3VzZXIvbG9naW4iLCJpYXQiOjE3MjQ4MTkyMjcsImV4cCI6MTcyNzQxMTIyNywibmJmIjoxNzI0ODE5MjI3LCJqdGkiOiI1OFVWQlNXMXpZU3lUS0JOIiwic3ViIjoiNjU2IiwicHJ2IjoiODY2NWFlOTc3NWNmMjZmNmI4ZTQ5NmY4NmZhNTM2ZDY4ZGQ3MTgxOCJ9.utQQomZB2RjePNsy7Zz5TmYawmHkCeVD0aOKNe30Zsc | string | 是 | - |
| lang | CN | string | 是 | - |

**Query**

##### 注单记录

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-04-13 11:11:31

> 更新时间: 2025-10-15 18:01:18

```text
暂无描述
```

**目录Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| 暂无参数 |

**目录Query参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| 暂无参数 |

**目录Body参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| 暂无参数 |

**目录认证信息**

> 继承父级

**Query**

###### 获取数据

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-04-13 11:11:32

> 更新时间: 2026-03-23 14:36:43

```text
暂无描述
```

**接口状态**

> 已完成

**接口URL**

> http://45.200.16.18:65535/api/gamerecord/getlist

**请求方式**

> POST

**Content-Type**

> json

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE3Mzo2NTUzNS9tL3VzZXIvbG9naW4iLCJpYXQiOjE3MjQ4MTkyMjcsImV4cCI6MTcyNzQxMTIyNywibmJmIjoxNzI0ODE5MjI3LCJqdGkiOiI1OFVWQlNXMXpZU3lUS0JOIiwic3ViIjoiNjU2IiwicHJ2IjoiODY2NWFlOTc3NWNmMjZmNmI4ZTQ5NmY4NmZhNTM2ZDY4ZGQ3MTgxOCJ9.utQQomZB2RjePNsy7Zz5TmYawmHkCeVD0aOKNe30Zsc | string | 是 | - |
| lang | CN | string | 是 | - |

**请求Body参数**

```javascript
{
    "page": 1,
    "size": 10,
    "api_code": "",
    "status": "",
    "code": "",
    "start_date": "2026-03-25",
    "end_date": "2026-03-25"
}
```

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| page | 1 | number | 是 | - |
| size | 10 | number | 是 | - |
| api_code | - | string | 是 | 接口 |
| status | - | string | 是 | 结算状态：1已结算，2未结算，3无效注单，4已退款 |
| code | - | string | 是 | 类型 |
| start_date | - | string | 是 | 开始时间，默认当天开始 |
| end_date | - | string | 是 | 结束时间，默认当天结束 |

**认证方式**

> 继承父级

**响应示例**

* 成功(200)

```javascript
{
	"code": 200,
	"msg": "success",
	"data": {
		"data": [
			{
				"id": 14706,
				"rowid": "123456789",
				"code": "live",
				"api_code": "1",
				"gameCode": null,
				"betTime": "2024-08-29 11:05:41",
				"betAmount": "0.00",
				"netAmount": "-50.00",
				"status": 1
			}
		],
		"current_page": 1,
		"total": 1,
		"total_betAmount": 0,
		"total_validBetAmount": 0,
		"total_netAmount": 0,
		"lastPage": 1
	}
}
```

| 参数名 | 示例值 | 参数类型 | 参数描述 |
| --- | --- | ---- | ---- |
| code | 200 | number | - |
| msg | success | string | - |
| data | - | object | - |
| data.data | - | array | - |
| data.data.id | 14706 | number | 数据ID |
| data.data.rowid | 123456789 | string | 单号 |
| data.data.code | live | string | 分类标识 |
| data.data.api_code | 1 | string | 记录标识 |
| data.data.gameCode | - | Null | - |
| data.data.betTime | 2024-08-29 11:05:41 | string | 记录时间 |
| data.data.betAmount | 0.00 | string | 记录金额 |
| data.data.netAmount | -50.00 | string | 记录结果 |
| data.data.status | 1 | number | 结算状态：1已结算，2未结算，3无效订单，4已退款 |
| data.current_page | 1 | number | - |
| data.total | 1 | number | 总条数 |
| data.lastPage | 1 | number | - |
| data.total_betAmount | - | string | 总投注 |
| data.total_validBetAmount | - | string | 总有效 |
| data.total_netAmount | - | string | 总盈亏 |

* 失败(404)

```javascript
{
	"code": 200,
	"msg": "success",
	"data": {
		"data": [],
		"current_page": 1,
		"total": 0,
		"lastPage": 0
	}
}
```

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE3Mzo2NTUzNS9tL3VzZXIvbG9naW4iLCJpYXQiOjE3MjQ4MTkyMjcsImV4cCI6MTcyNzQxMTIyNywibmJmIjoxNzI0ODE5MjI3LCJqdGkiOiI1OFVWQlNXMXpZU3lUS0JOIiwic3ViIjoiNjU2IiwicHJ2IjoiODY2NWFlOTc3NWNmMjZmNmI4ZTQ5NmY4NmZhNTM2ZDY4ZGQ3MTgxOCJ9.utQQomZB2RjePNsy7Zz5TmYawmHkCeVD0aOKNe30Zsc | string | 是 | - |
| lang | CN | string | 是 | - |

**Query**

##### 反水记录

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-04-13 11:11:31

> 更新时间: 2025-10-15 18:01:22

```text
暂无描述
```

**目录Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| 暂无参数 |

**目录Query参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| 暂无参数 |

**目录Body参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| 暂无参数 |

**目录认证信息**

> 继承父级

**Query**

###### 获取数据

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-04-13 11:11:32

> 更新时间: 2026-03-23 22:07:58

```text
暂无描述
```

**接口状态**

> 已完成

**接口URL**

> http://45.200.16.18:60000/api/member_fs_log/getlist

**请求方式**

> POST

**Content-Type**

> json

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjYwMDAwL2FwaS91c2VyL2xvZ2luIiwiaWF0IjoxNzc0Mjc0MTQzLCJleHAiOjE3NzY4NjYxNDMsIm5iZiI6MTc3NDI3NDE0MywianRpIjoiWEt6cVNFTnc3bE05ME9BVCIsInN1YiI6IjgxNyIsInBydiI6Ijg2NjVhZTk3NzVjZjI2ZjZiOGU0OTZmODZmYTUzNmQ2OGRkNzE4MTgifQ.uls2mT3JpVMNRTUiMOugrCbQ_bwPIpiYy51Z_vF7oqM | string | 是 | - |
| lang | CN | string | 是 | - |

**请求Body参数**

```javascript
{
    "page": 1,
    "size": 10,
    "code": "",
    "api_code": "",
    "status": "",
    "start_date": "",
    "end_date": ""
}
```

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| page | 1 | number | 是 | - |
| size | 10 | number | 是 | - |
| code | - | string | 否 | 类型 |
| api_code | - | string | 否 | 接口 |
| status | - | string | 否 | 状态：1已领取，0未领取 |
| start_date | 2025-12-10 | string | 否 | 开始时间 |
| end_date | 2025-12-11 | string | 否 | 结束时间 |

**认证方式**

> 继承父级

**响应示例**

* 成功(200)

```javascript
{
	"code": 200,
	"msg": "success",
	"data": {
		"data": [
			{
				"id": 2640,
				"username": "dd4646",
				"money": "0.0000",
				"api_code": "PGS",
				"code": "live",
				"bl": "1",
				"fs_money": "200.0000",
				"status": 1,
				"created_at": "2026-03-23 20:50:55",
				"api_code_title": "PG电子"
			}
		],
		"not_fs_money": "0.0000",
		"yes_fs_money": "200.0000",
		"total_fs_money": "200.0000",
		"current_page": 1,
		"total": 1,
		"lastPage": 1
	}
}
```

| 参数名 | 示例值 | 参数类型 | 参数描述 |
| --- | --- | ---- | ---- |
| code | 200 | number | - |
| msg | success | string | - |
| data | - | object | - |
| data.data | - | array | - |
| data.data.id | 2640 | number | 数据ID |
| data.data.username | dd4646 | string | 会员账号 |
| data.data.money | 0.0000 | string | 操作金额 |
| data.data.api_code | PGS | string | 游戏接口 |
| data.data.code | live | string | 游戏类型 |
| data.data.bl | 1 | string | 反水比例 |
| data.data.fs_money | 200.0000 | string | 反水金额 |
| data.data.status | 1 | number | 状态：1已领取，0未领取 |
| data.data.created_at | 2026-03-23 20:50:55 | string | 反水时间 |
| data.data.api_code_title | PG电子 | string | 接口名称 |
| data.not_fs_money | 0.0000 | number | 未领取反水金额 |
| data.yes_fs_money | 200.0000 | string | 已领取反水金额 |
| data.total_fs_money | 200.0000 | string | 总反水金额 |
| data.current_page | 1 | number | - |
| data.total | 1 | number | - |
| data.lastPage | 1 | number | - |

* 失败(200)

```javascript
暂无数据
```

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjYwMDAwL2FwaS91c2VyL2xvZ2luIiwiaWF0IjoxNzc0Mjc0MTQzLCJleHAiOjE3NzY4NjYxNDMsIm5iZiI6MTc3NDI3NDE0MywianRpIjoiWEt6cVNFTnc3bE05ME9BVCIsInN1YiI6IjgxNyIsInBydiI6Ijg2NjVhZTk3NzVjZjI2ZjZiOGU0OTZmODZmYTUzNmQ2OGRkNzE4MTgifQ.uls2mT3JpVMNRTUiMOugrCbQ_bwPIpiYy51Z_vF7oqM | string | 是 | - |
| lang | CN | string | 是 | - |

**Query**

###### 领取反水

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2026-01-22 22:22:50

> 更新时间: 2026-01-23 01:08:41

```text
暂无描述
```

**接口状态**

> 已完成

**接口URL**

> http://45.200.16.18:60000/api/member_fs_log/claim

**请求方式**

> POST

**Content-Type**

> none

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjYwMDAwL2FwaS91c2VyL2xvZ2luIiwiaWF0IjoxNzY5MDkxNDE3LCJleHAiOjE3NzE2ODM0MTcsIm5iZiI6MTc2OTA5MTQxNywianRpIjoicGx0Y0NRbVJhdDNaODRIdCIsInN1YiI6IjY2MiIsInBydiI6Ijg2NjVhZTk3NzVjZjI2ZjZiOGU0OTZmODZmYTUzNmQ2OGRkNzE4MTgifQ.saA9qznbdLxWy5cr2wpMkT6ExXM2qJvPipgIlLw58Ak | string | 是 | - |
| lang | CN | string | 是 | - |

**认证方式**

> 继承父级

**响应示例**

* 成功(200)

```javascript
{
	"code": 200,
	"msg": "领取成功",
	"data": []
}
```

| 参数名 | 示例值 | 参数类型 | 参数描述 |
| --- | --- | ---- | ---- |
| code | 200 | number | - |
| msg | 领取成功 | string | - |
| data | - | array | - |

* 失败(200)

```javascript
{
	"code": 0,
	"msg": "暂无可领取的反水"
}
```

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjYwMDAwL2FwaS91c2VyL2xvZ2luIiwiaWF0IjoxNzY5MDkxNDE3LCJleHAiOjE3NzE2ODM0MTcsIm5iZiI6MTc2OTA5MTQxNywianRpIjoicGx0Y0NRbVJhdDNaODRIdCIsInN1YiI6IjY2MiIsInBydiI6Ijg2NjVhZTk3NzVjZjI2ZjZiOGU0OTZmODZmYTUzNmQ2OGRkNzE4MTgifQ.saA9qznbdLxWy5cr2wpMkT6ExXM2qJvPipgIlLw58Ak | string | 是 | - |
| lang | CN | string | 是 | - |

**Query**

##### 转账记录

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-04-13 11:11:31

> 更新时间: 2025-10-15 18:01:29

```text
暂无描述
```

**目录Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| 暂无参数 |

**目录Query参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| 暂无参数 |

**目录Body参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| 暂无参数 |

**目录认证信息**

> 继承父级

**Query**

###### 获取数据

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-04-13 11:11:32

> 更新时间: 2025-12-11 16:37:32

```text
暂无描述
```

**接口状态**

> 已完成

**接口URL**

> http://45.200.16.18:60000/api/transfers_log/getlist

**请求方式**

> POST

**Content-Type**

> json

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjYwMDAwL2FwaS91c2VyL2xvZ2luIiwiaWF0IjoxNzQ1NjM4NTYzLCJleHAiOjE3NDgyMzA1NjMsIm5iZiI6MTc0NTYzODU2MywianRpIjoiYmFCb2pjOTJ6NGkybmREVyIsInN1YiI6IjY2MiIsInBydiI6Ijg2NjVhZTk3NzVjZjI2ZjZiOGU0OTZmODZmYTUzNmQ2OGRkNzE4MTgifQ.y4qobTcQalOrT-CcPEOPE6Bz-lAOH6zdfxDbXSro52k | string | 是 | - |
| lang | CN | string | 是 | - |

**请求Body参数**

```javascript
{
    "page": 1,
    "size": 10,
    "api_code": "",
    "status": "",
    "type": "",
    "start_date": "",
    "end_date": ""
}
```

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| page | 1 | number | 是 | - |
| size | 10 | number | 是 | - |
| api_code | - | string | 否 | 接口 |
| status | - | string | 否 | 状态：1成功，0失败 |
| type | - | string | 否 | 类型：1转入，2转出 |
| start_date | - | string | 否 | 开始时间 |
| end_date | - | string | 否 | 结束时间 |

**认证方式**

> 继承父级

**响应示例**

* 成功(200)

```javascript
{
	"code": 200,
	"msg": "success",
	"data": {
		"data": [
			{
				"id": 64,
				"order": "202409201857111726858631",
				"code": "DG",
				"money": "100.0000",
				"type": 2,
				"status": 1,
				"created_at": "2024-09-20 18:57:11"
			},
			{
				"id": 63,
				"order": "202409201857111726858631",
				"code": "BG",
				"money": "190.0000",
				"type": 2,
				"status": 1,
				"created_at": "2024-09-20 18:57:11"
			},
			{
				"id": 62,
				"order": "202409191057451726743465",
				"code": "BG",
				"money": "100.0000",
				"type": 1,
				"status": 1,
				"created_at": "2024-09-19 10:57:45"
			},
			{
				"id": 61,
				"order": "202409191057001726743420",
				"code": "BG",
				"money": "10.0000",
				"type": 2,
				"status": 1,
				"created_at": "2024-09-19 10:57:00"
			},
			{
				"id": 60,
				"order": "202409191056391726743399",
				"code": "DG",
				"money": "100.0000",
				"type": 1,
				"status": 1,
				"created_at": "2024-09-19 10:56:39"
			},
			{
				"id": 59,
				"order": "202409191056201726743380",
				"code": "BG",
				"money": "100.0000",
				"type": 1,
				"status": 1,
				"created_at": "2024-09-19 10:56:20"
			},
			{
				"id": 58,
				"order": "202409030613371725344017",
				"code": "BBIN",
				"money": "10.0000",
				"type": 2,
				"status": 1,
				"created_at": "2024-09-03 06:13:37"
			},
			{
				"id": 57,
				"order": "202409030613371725344017",
				"code": "AG",
				"money": "10.0000",
				"type": 2,
				"status": 1,
				"created_at": "2024-09-03 06:13:37"
			},
			{
				"id": 56,
				"order": "202409030613121725343992",
				"code": "BBIN",
				"money": "10.0000",
				"type": 1,
				"status": 1,
				"created_at": "2024-09-03 06:13:12"
			},
			{
				"id": 55,
				"order": "202409030613051725343985",
				"code": "AG",
				"money": "10.0000",
				"type": 1,
				"status": 1,
				"created_at": "2024-09-03 06:13:05"
			}
		],
		"current_page": 1,
		"total": 34,
		"lastPage": 4
	}
}
```

| 参数名 | 示例值 | 参数类型 | 参数描述 |
| --- | --- | ---- | ---- |
| code | 200 | number | - |
| msg | success | string | - |
| data | - | object | - |
| data.data | - | array | - |
| data.data.id | 64 | number | 数据ID |
| data.data.order | 202409201857111726858631 | string | 订单号 |
| data.data.code | DG | string | 转账接口 |
| data.data.money | 100.0000 | string | 金额 |
| data.data.type | 2 | number | 类型：1转入，2转出 |
| data.data.status | 1 | number | 状态：1成功，0失败 |
| data.data.created_at | 2024-09-20 18:57:11 | string | 转账时间 |
| data.current_page | 1 | number | - |
| data.total | 34 | number | 总条数，也是邀请注册人数 |
| data.lastPage | 4 | number | - |

* 失败(200)

```javascript
暂无数据
```

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjYwMDAwL2FwaS91c2VyL2xvZ2luIiwiaWF0IjoxNzQ1NjM4NTYzLCJleHAiOjE3NDgyMzA1NjMsIm5iZiI6MTc0NTYzODU2MywianRpIjoiYmFCb2pjOTJ6NGkybmREVyIsInN1YiI6IjY2MiIsInBydiI6Ijg2NjVhZTk3NzVjZjI2ZjZiOGU0OTZmODZmYTUzNmQ2OGRkNzE4MTgifQ.y4qobTcQalOrT-CcPEOPE6Bz-lAOH6zdfxDbXSro52k | string | 是 | - |
| lang | CN | string | 是 | - |

**Query**

##### 帐变记录

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2026-01-23 17:03:19

> 更新时间: 2026-01-23 17:03:59

```text
暂无描述
```

**目录Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| 暂无参数 |

**目录Query参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| 暂无参数 |

**目录Body参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| 暂无参数 |

**目录认证信息**

> 继承父级

**Query**

###### 获取帐变数据

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2026-01-23 17:03:19

> 更新时间: 2026-01-23 17:38:04

```text
暂无描述
```

**接口状态**

> 已完成

**接口URL**

> http://45.200.16.18:60000/api/money_log/getlist

**请求方式**

> POST

**Content-Type**

> json

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjYwMDAwL2FwaS91c2VyL2xvZ2luIiwiaWF0IjoxNzY5MDkxNDE3LCJleHAiOjE3NzE2ODM0MTcsIm5iZiI6MTc2OTA5MTQxNywianRpIjoicGx0Y0NRbVJhdDNaODRIdCIsInN1YiI6IjY2MiIsInBydiI6Ijg2NjVhZTk3NzVjZjI2ZjZiOGU0OTZmODZmYTUzNmQ2OGRkNzE4MTgifQ.saA9qznbdLxWy5cr2wpMkT6ExXM2qJvPipgIlLw58Ak | string | 是 | - |
| lang | CN | string | 是 | - |

**请求Body参数**

```javascript
{
    "page": 1,
    "size": 10,
    "order": "",
    "type": "",
    "money_type_id": "",
    "start_date": "2026-1-21",
    "end_date": "2026-1-23"
}
```

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| page | 1 | number | 是 | - |
| size | 10 | number | 是 | - |
| order | - | string | 否 | 单号 |
| type | - | integer | 否 | 类型：1增加，2减少 |
| money_type_id | - | string | 否 | 帐变类型ID |
| start_date | 2026-1-21 | string | 否 | 开始时间，默认当天开始时间 |
| end_date | 2026-1-23 | string | 否 | 结束时间，默认当天结束时间 |

**认证方式**

> 继承父级

**响应示例**

* 成功(200)

```javascript
{
	"code": 200,
	"msg": "success",
	"data": {
		"data": [
			{
				"order": "202512300555151767074115",
				"before_money": "1905.0000",
				"money": "20.0000",
				"after_money": "1925.0000",
				"type": 1,
				"money_type_id": 14,
				"note": "每周红包到账了！",
				"created_at": "2026-01-23 15:35:45"
			},
			{
				"order": "202512211535451766331345",
				"before_money": "1885.0000",
				"money": "20.0000",
				"after_money": "1905.0000",
				"type": 1,
				"money_type_id": 14,
				"note": "每周红包到账了！",
				"created_at": "2026-01-23 15:35:45"
			},
			{
				"order": "202512211535451766331345",
				"before_money": "1835.0000",
				"money": "50.0000",
				"after_money": "1885.0000",
				"type": 1,
				"money_type_id": 12,
				"note": "恭喜您升级了",
				"created_at": "2026-01-23 15:35:45"
			}
		],
		"money_type": [
			{
				"id": 9,
				"name": "后台增加"
			},
			{
				"id": 10,
				"name": "后台扣除"
			},
			{
				"id": 11,
				"name": "反水"
			},
			{
				"id": 12,
				"name": "升级赠送"
			},
			{
				"id": 13,
				"name": "生日礼金"
			},
			{
				"id": 14,
				"name": "周红包"
			},
			{
				"id": 15,
				"name": "月红包"
			},
			{
				"id": 16,
				"name": "流水佣金"
			},
			{
				"id": 17,
				"name": "盈亏佣金"
			},
			{
				"id": 18,
				"name": "全民返利"
			}
		],
		"current_page": 1,
		"total": 3,
		"lastPage": 1
	}
}
```

| 参数名 | 示例值 | 参数类型 | 参数描述 |
| --- | --- | ---- | ---- |
| code | 200 | number | - |
| msg | success | string | - |
| data | - | object | - |
| data.data | - | array | - |
| data.data.order | 202512300555151767074115 | string | 单号 |
| data.data.before_money | 1905.0000 | string | 变动前 |
| data.data.money | 20.0000 | string | 变动金额 |
| data.data.after_money | 1925.0000 | string | 变动后 |
| data.data.type | 1 | number | 类型：1增加，2减少 |
| data.data.money_type_id | 14 | number | 帐变类型ID |
| data.data.note | 每周红包到账了！ | string | 备注 |
| data.data.created_at | 2026-01-23 15:35:45 | string | 变动时间 |
| data.money_type | - | array | 变动类型 |
| data.money_type.id | 9 | number | 类型id |
| data.money_type.name | 后台增加 | string | 类型解释 |
| data.current_page | 1 | number | - |
| data.total | 3 | number | - |
| data.lastPage | 1 | number | - |

* 失败(200)

```javascript
暂无数据
```

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjYwMDAwL2FwaS91c2VyL2xvZ2luIiwiaWF0IjoxNzY5MDkxNDE3LCJleHAiOjE3NzE2ODM0MTcsIm5iZiI6MTc2OTA5MTQxNywianRpIjoicGx0Y0NRbVJhdDNaODRIdCIsInN1YiI6IjY2MiIsInBydiI6Ijg2NjVhZTk3NzVjZjI2ZjZiOGU0OTZmODZmYTUzNmQ2OGRkNzE4MTgifQ.saA9qznbdLxWy5cr2wpMkT6ExXM2qJvPipgIlLw58Ak | string | 是 | - |
| lang | CN | string | 是 | - |

**Query**

#### 充值

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-04-13 11:11:31

> 更新时间: 2025-10-15 18:08:09

```text
暂无描述
```

**目录Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| 暂无参数 |

**目录Query参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| 暂无参数 |

**目录Body参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| 暂无参数 |

**目录认证信息**

> 继承父级

**Query**

##### 获取充值分类

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-04-13 11:11:32

> 更新时间: 2026-03-23 01:36:32

```text
暂无描述
```

**接口状态**

> 已完成

**接口URL**

> http://45.200.16.18:65535/api/deposit/class

**请求方式**

> POST

**Content-Type**

> json

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE3Mzo2NTUzNS9tL3VzZXIvbG9naW4iLCJpYXQiOjE3MjQ4MTkyMjcsImV4cCI6MTcyNzQxMTIyNywibmJmIjoxNzI0ODE5MjI3LCJqdGkiOiI1OFVWQlNXMXpZU3lUS0JOIiwic3ViIjoiNjU2IiwicHJ2IjoiODY2NWFlOTc3NWNmMjZmNmI4ZTQ5NmY4NmZhNTM2ZDY4ZGQ3MTgxOCJ9.utQQomZB2RjePNsy7Zz5TmYawmHkCeVD0aOKNe30Zsc | string | 是 | - |
| lang | CN | string | 是 | - |

**请求Body参数**

```javascript
暂无数据
```

**认证方式**

> 继承父级

**响应示例**

* 成功(200)

```javascript
{
	"code": 200,
	"msg": "success",
	"data": [
		{
			"id": 29,
			"code": "1",
			"title": "微信支付12",
			"msg": ""
		}
	]
}
```

| 参数名 | 示例值 | 参数类型 | 参数描述 |
| --- | --- | ---- | ---- |
| code | 200 | number | - |
| msg | success | string | - |
| data | - | array | - |
| data.id | 29 | number | 数据ID |
| data.code | 1 | string | 分类标识 |
| data.title | 微信支付12 | string | 分类标题 |
| data.msg | - | string | 描述 |

* 失败(200)

```javascript
暂无数据
```

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE3Mzo2NTUzNS9tL3VzZXIvbG9naW4iLCJpYXQiOjE3MjQ4MTkyMjcsImV4cCI6MTcyNzQxMTIyNywibmJmIjoxNzI0ODE5MjI3LCJqdGkiOiI1OFVWQlNXMXpZU3lUS0JOIiwic3ViIjoiNjU2IiwicHJ2IjoiODY2NWFlOTc3NWNmMjZmNmI4ZTQ5NmY4NmZhNTM2ZDY4ZGQ3MTgxOCJ9.utQQomZB2RjePNsy7Zz5TmYawmHkCeVD0aOKNe30Zsc | string | 是 | - |
| lang | CN | string | 是 | - |

**Query**

##### 获取充值分类下的通道

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-04-13 11:11:32

> 更新时间: 2025-04-13 11:11:32

```text
暂无描述
```

**接口状态**

> 已完成

**接口URL**

> http://45.200.16.18:65535/api/deposit/getlist

**请求方式**

> POST

**Content-Type**

> json

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjY1NTM1L2FwaS91c2VyL2xvZ2luIiwiaWF0IjoxNzQxNTM2NTg3LCJleHAiOjE3NDQxMjg1ODcsIm5iZiI6MTc0MTUzNjU4NywianRpIjoiUXd2cERuMkJOaGhRUmluOCIsInN1YiI6IjY2MiIsInBydiI6Ijg2NjVhZTk3NzVjZjI2ZjZiOGU0OTZmODZmYTUzNmQ2OGRkNzE4MTgifQ.5rfpZxGr4PWIXlVx13bnYfyCK0SUGdv3_VUtbWrZgJA | string | 是 | - |
| lang | CN | string | 是 | - |

**请求Body参数**

```javascript
{
    "id": 31
}
```

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| id | 19 | number | 否 | 分类id，不传则返回所有通道 |

**认证方式**

> 继承父级

**响应示例**

* 成功(200)

```javascript
{
	"code": 200,
	"msg": "success",
	"data": [
		{
			"id": 25,
			"min": "0.0000",
			"max": "0.0000",
			"amount_type": 3,
			"amount": [
				"100",
				"200",
				"300"
			],
			"title": "USDT-TRC20",
			"rete": "7.2339"
		},
		{
			"id": 27,
			"min": "0.0000",
			"max": "0.0000",
			"amount_type": 3,
			"amount": [
				"100",
				"200",
				"300"
			],
			"title": "TOpay"
		}
	]
}
```

| 参数名 | 示例值 | 参数类型 | 参数描述 |
| --- | --- | ---- | ---- |
| code | 200 | number | - |
| msg | success | string | - |
| data | - | array | - |
| data.id | 25 | number | 数据ID |
| data.min | 0.0000 | string | 最低支付金额，0不限制 |
| data.max | 0.0000 | string | 最高支付金额，0不限制 |
| data.amount_type | 3 | number | 金额类型：1手动输入，2固定金额，3通用，=1只可以手动输入，=2只可以选择固定金额。=3两个都可以用 |
| data.amount | - | array | 固定金额 |
| data.title | USDT-TRC20 | string | 通道标题 |
| data.rete | 7.2339 | string | 前端检测title是否包含USDT关键字，如果存在就会显示该参数，该参数为汇率 |

* 失败(200)

```javascript
暂无数据
```

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjY1NTM1L2FwaS91c2VyL2xvZ2luIiwiaWF0IjoxNzQxNTM2NTg3LCJleHAiOjE3NDQxMjg1ODcsIm5iZiI6MTc0MTUzNjU4NywianRpIjoiUXd2cERuMkJOaGhRUmluOCIsInN1YiI6IjY2MiIsInBydiI6Ijg2NjVhZTk3NzVjZjI2ZjZiOGU0OTZmODZmYTUzNmQ2OGRkNzE4MTgifQ.5rfpZxGr4PWIXlVx13bnYfyCK0SUGdv3_VUtbWrZgJA | string | 是 | - |
| lang | CN | string | 是 | - |

**Query**

##### 提交充值

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-04-13 11:11:32

> 更新时间: 2026-03-25 22:30:45

```text
暂无描述
```

**接口状态**

> 已完成

**接口URL**

> http://45.200.16.18:60000/api/recharge/order

**请求方式**

> POST

**Content-Type**

> json

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjYwMDAwL2FwaS91c2VyL2xvZ2luIiwiaWF0IjoxNzY5NjExNzY2LCJleHAiOjE3NzIyMDM3NjYsIm5iZiI6MTc2OTYxMTc2NiwianRpIjoieGRHZTZobDFVcHNubG9YQyIsInN1YiI6IjY2MiIsInBydiI6Ijg2NjVhZTk3NzVjZjI2ZjZiOGU0OTZmODZmYTUzNmQ2OGRkNzE4MTgifQ.B4gd1LLsNzSWmeuFOxxD-1h0Au7E0XExbCD-GjZJvFc | string | 是 | - |
| lang | CN | string | 是 | - |

**请求Body参数**

```javascript
{
    "id": 30,
    "money": 100
}
```

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| id | 26 | number | 是 | 通道ID |
| money | 100.5678 | number | 是 | 充值金额 |

**认证方式**

> 继承父级

**响应示例**

* 成功(200)

```javascript
{
	"code": 200,
	"msg": "success",
	"data": {
		"params": {
			"bank_name": "张三",
			"bank": "建设银行",
			"card": "45649489494949849",
			"address": "北京市顺义区"
		},
		"type": 4,
		"nesting": true
	}
}
```

| 参数名 | 示例值 | 参数类型 | 参数描述 |
| --- | --- | ---- | ---- |
| code | 200 | number | - |
| msg | success | string | - |
| data | - | object | - |
| data.params | - | object | 支付参数 |
| data.params.bank_name | 张三 | string | 开户名，type=4时参数 |
| data.params.bank | 建设银行 | string | 开户行，type=4时参数 |
| data.params.card | 45649489494949849 | string | 卡号，type=4时参数 |
| data.params.address | 北京市顺义区 | string | 开户地，type=4时参数 |
| data.type | 4 | number | 支付类型，此处有4种数据格式，具体对接请核对下 |
| data.nesting | true | boolean | 是否允许嵌套：true是，false否，注意此参数只有在线支持的时候才有 |

* 失败(200)

```javascript
{
	"code": 0,
	"msg": "当前通道最高充值金额 55555.0000"
}
```

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjYwMDAwL2FwaS91c2VyL2xvZ2luIiwiaWF0IjoxNzY5NjExNzY2LCJleHAiOjE3NzIyMDM3NjYsIm5iZiI6MTc2OTYxMTc2NiwianRpIjoieGRHZTZobDFVcHNubG9YQyIsInN1YiI6IjY2MiIsInBydiI6Ijg2NjVhZTk3NzVjZjI2ZjZiOGU0OTZmODZmYTUzNmQ2OGRkNzE4MTgifQ.B4gd1LLsNzSWmeuFOxxD-1h0Au7E0XExbCD-GjZJvFc | string | 是 | - |
| lang | CN | string | 是 | - |

**Query**

##### 获取订单详情type=4

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-04-13 11:11:32

> 更新时间: 2026-02-20 00:32:20

```text
暂无描述
```

**接口状态**

> 已完成

**接口URL**

> http://45.200.16.18:65535/api/recharge/details

**请求方式**

> POST

**Content-Type**

> json

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjY1NTM1L20vdXNlci9sb2dpbiIsImlhdCI6MTcyODI3NzYzMSwiZXhwIjoxNzMwODY5NjMxLCJuYmYiOjE3MjgyNzc2MzEsImp0aSI6Im10TG44YlBBTDYzYjcyTUoiLCJzdWIiOiI2NTYiLCJwcnYiOiI4NjY1YWU5Nzc1Y2YyNmY2YjhlNDk2Zjg2ZmE1MzZkNjhkZDcxODE4In0.3cV_L1wRbK5YGoAvP9jISAPXoUwsH-2HKSdujOjAS5M | string | 是 | - |
| lang | CN | string | 是 | - |

**请求Body参数**

```javascript
{
    "id": 62
}
```

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| id | 62 | number | 是 | 数据ID |

**认证方式**

> 继承父级

**响应示例**

* 成功(200)

```javascript
{
	"code": 200,
	"msg": "success",
	"data": {
		"params": {
			"bank_name": "张三", //开户姓名
			"bank": "建设银行", //开户行
			"card": "45649489494949849", //卡号
			"address": "北京市顺义区" //开户地
		},
		"money": "12345.0000", //充值金额
		"hl": 6.54, //USDT汇率
		"usdt_money": "0",//实际支付USDT数量
		"img": null, //二维码
		"currency": "CNY", //货币
		"type": 4 //type=4 时 data数据结构，页面展示 货币，充值金额，开户行 开户姓名 卡号 开户地
	}
}
```

| 参数名 | 示例值 | 参数类型 | 参数描述 |
| --- | --- | ---- | ---- |
| code | 200 | number | - |
| msg | success | string | - |
| data | - | object | - |
| data.params | - | object | 支付参数 |
| data.params.bank_name | 张三 | string | 开户姓名 |
| data.params.bank | 建设银行 | string | 开户行 |
| data.params.card | 45649489494949849 | string | 卡号 |
| data.params.address | 北京市顺义区 | string | 开户地 |
| data.money | 12345.0000 | string | 充值金额 |
| data.hl | 6.54 | number | USDT汇率 |
| data.img | - | Null | 二维码 |
| data.currency | CNY | string | 货币 |
| data.type | 4 | number | type=4 时 data数据结构，页面展示 货币，充值金额，开户行 开户姓名 卡号 开户地 |
| data.usdt_money | - | string | 实际支付USDT数量 |

* 失败(200)

```javascript
{
	"code": 0,
	"msg": "order errors"
}
```

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjY1NTM1L20vdXNlci9sb2dpbiIsImlhdCI6MTcyODI3NzYzMSwiZXhwIjoxNzMwODY5NjMxLCJuYmYiOjE3MjgyNzc2MzEsImp0aSI6Im10TG44YlBBTDYzYjcyTUoiLCJzdWIiOiI2NTYiLCJwcnYiOiI4NjY1YWU5Nzc1Y2YyNmY2YjhlNDk2Zjg2ZmE1MzZkNjhkZDcxODE4In0.3cV_L1wRbK5YGoAvP9jISAPXoUwsH-2HKSdujOjAS5M | string | 是 | - |
| lang | CN | string | 是 | - |

**Query**

##### 获取订单详情type=3

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-04-13 11:11:32

> 更新时间: 2025-04-13 11:11:32

```text
暂无描述
```

**接口状态**

> 已完成

**接口URL**

> http://45.200.16.18:65535/api/recharge/details

**请求方式**

> POST

**Content-Type**

> json

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjY1NTM1L20vdXNlci9sb2dpbiIsImlhdCI6MTcyODI3NzYzMSwiZXhwIjoxNzMwODY5NjMxLCJuYmYiOjE3MjgyNzc2MzEsImp0aSI6Im10TG44YlBBTDYzYjcyTUoiLCJzdWIiOiI2NTYiLCJwcnYiOiI4NjY1YWU5Nzc1Y2YyNmY2YjhlNDk2Zjg2ZmE1MzZkNjhkZDcxODE4In0.3cV_L1wRbK5YGoAvP9jISAPXoUwsH-2HKSdujOjAS5M | string | 是 | - |
| lang | CN | string | 是 | - |

**请求Body参数**

```javascript
{
    "id": 62
}
```

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| id | 62 | number | 是 | 数据ID |

**认证方式**

> 继承父级

**响应示例**

* 成功(200)

```javascript
{
	"code": 200,
	"msg": "success",
	"data": {
		"params": {
			"addres": "fdsaf48gfdgfdsgfds" //收款地址
		},
		"money": "12345.0000", //充值金额
		"hl": 6.54, //USDT汇率
		"usdt_money": "1,722.3579",  //实际支付USDT数量
		"img": null, //二维码
		"currency": "CNY", //货币
		"type": 3 //type=3 时 data数据结构，页面展示 货币，充值金额，收款地址 二维码 虚拟币数量=充值金额/USDT汇率
	}
}
```

| 参数名 | 示例值 | 参数类型 | 参数描述 |
| --- | --- | ---- | ---- |
| code | 200 | number | - |
| msg | success | string | - |
| data | - | object | - |
| data.params | - | object | 支付参数 |
| data.params.addres | fdsaf48gfdgfdsgfds | string | 收款地址 |
| data.money | 12345.0000 | string | 充值金额 |
| data.hl | 6.54 | number | USDT汇率 |
| data.img | - | null | 二维码 |
| data.currency | CNY | string | 货币 |
| data.type | 3 | number | type=3 时 data数据结构，页面展示 货币，充值金额，收款地址 二维码 虚拟币数量=充值金额/USDT汇率 |

* 失败(200)

```javascript
{
	"code": 0,
	"msg": "order errors"
}
```

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjY1NTM1L20vdXNlci9sb2dpbiIsImlhdCI6MTcyODI3NzYzMSwiZXhwIjoxNzMwODY5NjMxLCJuYmYiOjE3MjgyNzc2MzEsImp0aSI6Im10TG44YlBBTDYzYjcyTUoiLCJzdWIiOiI2NTYiLCJwcnYiOiI4NjY1YWU5Nzc1Y2YyNmY2YjhlNDk2Zjg2ZmE1MzZkNjhkZDcxODE4In0.3cV_L1wRbK5YGoAvP9jISAPXoUwsH-2HKSdujOjAS5M | string | 是 | - |
| lang | CN | string | 是 | - |

**Query**

##### 获取订单详情type=2

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-04-13 11:11:32

> 更新时间: 2026-02-20 00:33:24

```text
暂无描述
```

**接口状态**

> 已完成

**接口URL**

> http://45.200.16.18:65535/api/recharge/details

**请求方式**

> POST

**Content-Type**

> json

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjY1NTM1L20vdXNlci9sb2dpbiIsImlhdCI6MTcyODI3NzYzMSwiZXhwIjoxNzMwODY5NjMxLCJuYmYiOjE3MjgyNzc2MzEsImp0aSI6Im10TG44YlBBTDYzYjcyTUoiLCJzdWIiOiI2NTYiLCJwcnYiOiI4NjY1YWU5Nzc1Y2YyNmY2YjhlNDk2Zjg2ZmE1MzZkNjhkZDcxODE4In0.3cV_L1wRbK5YGoAvP9jISAPXoUwsH-2HKSdujOjAS5M | string | 是 | - |
| lang | CN | string | 是 | - |

**请求Body参数**

```javascript
{
    "id": 62
}
```

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| id | 62 | number | 是 | 数据ID |

**认证方式**

> 继承父级

**响应示例**

* 成功(200)

```javascript
{
	"code": 200,
	"msg": "success",
	"data": {
		"params": {
			"name": "123", //姓名
			"account": "12345649789" //账号
		},
		"money": "12345.0000", //充值金额
		"hl": 6.54, //USDT汇率
		"usdt_money": "0",//实际支付USDT数量
		"img": null, //二维码
		"currency": "CNY", //货币
		"type": 2 //type=2 时 data数据结构，页面展示 货币，充值金额，姓名 账号 二维码
	}
}
```

| 参数名 | 示例值 | 参数类型 | 参数描述 |
| --- | --- | ---- | ---- |
| code | 200 | number | - |
| msg | success | string | - |
| data | - | object | - |
| data.params | - | object | 支付参数 |
| data.params.name | 123 | string | 姓名 |
| data.params.account | 12345649789 | string | 账号 |
| data.money | 12345.0000 | string | 充值金额 |
| data.hl | 6.54 | number | USDT汇率 |
| data.img | - | Null | 二维码 |
| data.currency | CNY | string | 货币 |
| data.type | 2 | number | type=2 时 data数据结构，页面展示 货币，充值金额，姓名 账号 二维码 |
| data.usdt_money | - | string | 实际支付USDT数量 |

* 失败(200)

```javascript
{
	"code": 0,
	"msg": "order errors"
}
```

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjY1NTM1L20vdXNlci9sb2dpbiIsImlhdCI6MTcyODI3NzYzMSwiZXhwIjoxNzMwODY5NjMxLCJuYmYiOjE3MjgyNzc2MzEsImp0aSI6Im10TG44YlBBTDYzYjcyTUoiLCJzdWIiOiI2NTYiLCJwcnYiOiI4NjY1YWU5Nzc1Y2YyNmY2YjhlNDk2Zjg2ZmE1MzZkNjhkZDcxODE4In0.3cV_L1wRbK5YGoAvP9jISAPXoUwsH-2HKSdujOjAS5M | string | 是 | - |
| lang | CN | string | 是 | - |

**Query**

##### 取消支付

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-04-13 11:11:32

> 更新时间: 2025-04-13 11:11:32

```text
暂无描述
```

**接口状态**

> 已完成

**接口URL**

> http://45.200.16.18:65535/api/recharge/cancel

**请求方式**

> POST

**Content-Type**

> json

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjY1NTM1L20vdXNlci9sb2dpbiIsImlhdCI6MTcyODQ0OTI3MiwiZXhwIjoxNzMxMDQxMjcyLCJuYmYiOjE3Mjg0NDkyNzIsImp0aSI6Ill5aGRRcEpPVXlvWGdnRG0iLCJzdWIiOiI2NTYiLCJwcnYiOiI4NjY1YWU5Nzc1Y2YyNmY2YjhlNDk2Zjg2ZmE1MzZkNjhkZDcxODE4In0.Hlp-bYgGrLPj3ZK9ji9exD_XQWGRoi3qZ0KTkzfN4Hc | string | 是 | - |
| lang | CN | string | 是 | - |

**请求Body参数**

```javascript
{
    "id": 30,
    "note": "没钱了，躺平了"
}
```

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| id | 30 | number | 是 | 数据ID，订单详情有返回数据ID |
| note | 没钱了，躺平了 | string | 是 | 取消原因 |

**认证方式**

> 继承父级

**响应示例**

* 成功(200)

```javascript
{
	"code": 200,
	"msg": "操作成功",
	"data": []
}
```

* 失败(404)

```javascript
{
	"code": 0,
	"msg": "数据不存在"
}
```

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjY1NTM1L20vdXNlci9sb2dpbiIsImlhdCI6MTcyODQ0OTI3MiwiZXhwIjoxNzMxMDQxMjcyLCJuYmYiOjE3Mjg0NDkyNzIsImp0aSI6Ill5aGRRcEpPVXlvWGdnRG0iLCJzdWIiOiI2NTYiLCJwcnYiOiI4NjY1YWU5Nzc1Y2YyNmY2YjhlNDk2Zjg2ZmE1MzZkNjhkZDcxODE4In0.Hlp-bYgGrLPj3ZK9ji9exD_XQWGRoi3qZ0KTkzfN4Hc | string | 是 | - |
| lang | CN | string | 是 | - |

**Query**

##### 上传支付凭证

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-04-13 11:11:32

> 更新时间: 2025-10-07 19:14:18

```text
暂无描述
```

**接口状态**

> 已完成

**接口URL**

> http://45.200.16.18:65535/api/recharge/img

**请求方式**

> POST

**Content-Type**

> json

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjY1NTM1L20vdXNlci9sb2dpbiIsImlhdCI6MTcyODQ0OTI3MiwiZXhwIjoxNzMxMDQxMjcyLCJuYmYiOjE3Mjg0NDkyNzIsImp0aSI6Ill5aGRRcEpPVXlvWGdnRG0iLCJzdWIiOiI2NTYiLCJwcnYiOiI4NjY1YWU5Nzc1Y2YyNmY2YjhlNDk2Zjg2ZmE1MzZkNjhkZDcxODE4In0.Hlp-bYgGrLPj3ZK9ji9exD_XQWGRoi3qZ0KTkzfN4Hc | string | 是 | - |
| lang | CN | string | 是 | - |

**请求Body参数**

```javascript
{
    "id": 30,
    "img": ""
}
```

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| id | 30 | number | 是 | 数据ID，订单详情有返回数据ID |
| img | - | string | 是 | 上传支付凭证时返回的图片地址 |

**认证方式**

> 继承父级

**响应示例**

* 成功(200)

```javascript
{
	"code": 200,
	"msg": "操作成功",
	"data": []
}
```

* 失败(404)

```javascript
{
	"code": 0,
	"msg": "数据不存在"
}
```

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjY1NTM1L20vdXNlci9sb2dpbiIsImlhdCI6MTcyODQ0OTI3MiwiZXhwIjoxNzMxMDQxMjcyLCJuYmYiOjE3Mjg0NDkyNzIsImp0aSI6Ill5aGRRcEpPVXlvWGdnRG0iLCJzdWIiOiI2NTYiLCJwcnYiOiI4NjY1YWU5Nzc1Y2YyNmY2YjhlNDk2Zjg2ZmE1MzZkNjhkZDcxODE4In0.Hlp-bYgGrLPj3ZK9ji9exD_XQWGRoi3qZ0KTkzfN4Hc | string | 是 | - |
| lang | CN | string | 是 | - |

**Query**

#### 提现

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-04-13 11:11:31

> 更新时间: 2025-10-15 18:08:19

```text
暂无描述
```

**目录Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| 暂无参数 |

**目录Query参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| 暂无参数 |

**目录Body参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| 暂无参数 |

**目录认证信息**

> 继承父级

**Query**

##### 获取会员卡包资料

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-04-13 11:11:32

> 更新时间: 2025-12-11 15:27:10

```text
暂无描述
```

**接口状态**

> 已完成

**接口URL**

> http://45.200.16.18:60000/api/drawing/getlist

**请求方式**

> POST

**Content-Type**

> none

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjYwMDAwL2FwaS91c2VyL3JlZ2lzdGVyIiwiaWF0IjoxNzY1NDM3MDU4LCJleHAiOjE3NjgwMjkwNTgsIm5iZiI6MTc2NTQzNzA1OCwianRpIjoibkFqVVZUVUhWaFVHT3R1MCIsInN1YiI6Ijc0MSIsInBydiI6Ijg2NjVhZTk3NzVjZjI2ZjZiOGU0OTZmODZmYTUzNmQ2OGRkNzE4MTgifQ.kvxspraCKt1FlqsibeJA04Oz8MLTfbmhLqalVNKOQkw | string | 是 | - |
| lang | CN | string | 是 | - |

**认证方式**

> 继承父级

**响应示例**

* 成功(200)

```javascript
{
	"code": 200,
	"msg": "success",
	"data": [
		{
			"id": 20,
			"card": "2355566666677",
			"img": null,
			"type": 2,
			"title": "USDT-ERC20"
		}
	]
}
```

| 参数名 | 示例值 | 参数类型 | 参数描述 |
| --- | --- | ---- | ---- |
| code | 200 | number | - |
| msg | success | string | - |
| data | - | array | - |
| data.id | 20 | number | - |
| data.card | 2355566666677 | string | - |
| data.img | - | Null | - |
| data.type | 2 | number | 类型：1银行卡，2虚拟币，3支付宝 |
| data.title | USDT-ERC20 | string | - |

* 失败(200)

```javascript
暂无数据
```

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjYwMDAwL2FwaS91c2VyL3JlZ2lzdGVyIiwiaWF0IjoxNzY1NDM3MDU4LCJleHAiOjE3NjgwMjkwNTgsIm5iZiI6MTc2NTQzNzA1OCwianRpIjoibkFqVVZUVUhWaFVHT3R1MCIsInN1YiI6Ijc0MSIsInBydiI6Ijg2NjVhZTk3NzVjZjI2ZjZiOGU0OTZmODZmYTUzNmQ2OGRkNzE4MTgifQ.kvxspraCKt1FlqsibeJA04Oz8MLTfbmhLqalVNKOQkw | string | 是 | - |
| lang | CN | string | 是 | - |

**Query**

##### 确定取款

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-04-13 11:11:32

> 更新时间: 2025-12-11 15:28:19

```text
暂无描述
```

**接口状态**

> 已完成

**接口URL**

> http://45.200.16.18:60000/api/drawing/order

**请求方式**

> POST

**Content-Type**

> json

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjYwMDAwL2FwaS91c2VyL3JlZ2lzdGVyIiwiaWF0IjoxNzY1NDM3MDU4LCJleHAiOjE3NjgwMjkwNTgsIm5iZiI6MTc2NTQzNzA1OCwianRpIjoibkFqVVZUVUhWaFVHT3R1MCIsInN1YiI6Ijc0MSIsInBydiI6Ijg2NjVhZTk3NzVjZjI2ZjZiOGU0OTZmODZmYTUzNmQ2OGRkNzE4MTgifQ.kvxspraCKt1FlqsibeJA04Oz8MLTfbmhLqalVNKOQkw | string | 是 | - |
| lang | CN | string | 是 | - |

**请求Body参数**

```javascript
{
    "id": 45,
    "money": 500,
    "pay_password": "123456"
}
```

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| id | 10 | number | 是 | 卡包ID |
| money | 500 | number | 是 | 取款金额 |
| pay_password | 123456 | string | 是 | 安全码，6-20位 |

**认证方式**

> 继承父级

**响应示例**

* 成功(200)

```javascript
{
	"code": 200,
	"msg": "取款成功",
	"data": []
}
```

| 参数名 | 示例值 | 参数类型 | 参数描述 |
| --- | --- | ---- | ---- |
| code | 200 | number | - |
| msg | 取款成功 | string | - |
| data | - | array | - |

* 失败(200)

```javascript
暂无数据
```

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjYwMDAwL2FwaS91c2VyL3JlZ2lzdGVyIiwiaWF0IjoxNzY1NDM3MDU4LCJleHAiOjE3NjgwMjkwNTgsIm5iZiI6MTc2NTQzNzA1OCwianRpIjoibkFqVVZUVUhWaFVHT3R1MCIsInN1YiI6Ijc0MSIsInBydiI6Ijg2NjVhZTk3NzVjZjI2ZjZiOGU0OTZmODZmYTUzNmQ2OGRkNzE4MTgifQ.kvxspraCKt1FlqsibeJA04Oz8MLTfbmhLqalVNKOQkw | string | 是 | - |
| lang | CN | string | 是 | - |

**Query**

#### 全民返利

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2026-01-20 17:32:00

> 更新时间: 2026-01-20 17:32:00

```text
暂无描述
```

**目录Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| 暂无参数 |

**目录Query参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| 暂无参数 |

**目录Body参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| 暂无参数 |

**目录认证信息**

> 继承父级

**Query**

##### 获取数据

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2026-01-20 17:55:53

> 更新时间: 2026-01-21 01:17:12

**满X元，且有效人数>=X人，即可领取,满X，且再邀请user_max - user_youxiao 人，即可多领取 user_amoun**

**接口状态**

> 已完成

**接口URL**

> http://45.200.16.18:60000/api/retabe/list

**请求方式**

> POST

**Content-Type**

> none

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| lang | CN | string | 是 | - |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjYwMDAwL2FwaS91c2VyL2xvZ2luIiwiaWF0IjoxNzY4OTAzMDA5LCJleHAiOjE3NzE0OTUwMDksIm5iZiI6MTc2ODkwMzAwOSwianRpIjoiRmFMaGpKckFxMDNxUjF5QyIsInN1YiI6IjE3IiwicHJ2IjoiODY2NWFlOTc3NWNmMjZmNmI4ZTQ5NmY4NmZhNTM2ZDY4ZGQ3MTgxOCJ9.-_9KLJL8toCjUzB51oS_x6Lk0ajK03poWOmyFpbu4uc | string | 是 | - |

**认证方式**

> 继承父级

**响应示例**

* 成功(200)

```javascript
{
	"code": 200,
	"msg": "success",
	"data": {
		"user_sum": 0,
		"user_youxiao": 0,
		"dailingqu": 0,
		"zuidi": "1",
		"user_max": 0,
		"user_amount": 0
	}
}
```

| 参数名 | 示例值 | 参数类型 | 参数描述 |
| --- | --- | ---- | ---- |
| code | 200 | number | - |
| msg | success | string | 错误信息 |
| data | - | object | - |
| data.user_sum | 0 | number | 总会员人数 |
| data.user_youxiao | 0 | number | 总有效会员 |
| data.dailingqu | 0 | number | 待领取金额 |
| data.zuidi | 1 | string | 最低金额为有效会员 |
| data.user_max | 0 | number | 下一级>= |
| data.user_amount | 0 | number | 下一级可领取金额 |

* 失败(200)

```javascript
暂无数据
```

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| lang | CN | string | 是 | - |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjYwMDAwL2FwaS91c2VyL2xvZ2luIiwiaWF0IjoxNzY4OTAzMDA5LCJleHAiOjE3NzE0OTUwMDksIm5iZiI6MTc2ODkwMzAwOSwianRpIjoiRmFMaGpKckFxMDNxUjF5QyIsInN1YiI6IjE3IiwicHJ2IjoiODY2NWFlOTc3NWNmMjZmNmI4ZTQ5NmY4NmZhNTM2ZDY4ZGQ3MTgxOCJ9.-_9KLJL8toCjUzB51oS_x6Lk0ajK03poWOmyFpbu4uc | string | 是 | - |

**Query**

##### 领取红利

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2026-01-21 12:11:11

> 更新时间: 2026-01-21 12:36:48

**满X元，且有效人数>=X人，即可领取,满X，且再邀请user_max - user_youxiao 人，即可多领取 user_amoun**

**接口状态**

> 已完成

**接口URL**

> http://45.200.16.18:60000/api/retabe/amount

**请求方式**

> POST

**Content-Type**

> none

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| lang | CN | string | 是 | - |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjYwMDAwL2FwaS91c2VyL2xvZ2luIiwiaWF0IjoxNzY4OTAzMDA5LCJleHAiOjE3NzE0OTUwMDksIm5iZiI6MTc2ODkwMzAwOSwianRpIjoiRmFMaGpKckFxMDNxUjF5QyIsInN1YiI6IjE3IiwicHJ2IjoiODY2NWFlOTc3NWNmMjZmNmI4ZTQ5NmY4NmZhNTM2ZDY4ZGQ3MTgxOCJ9.-_9KLJL8toCjUzB51oS_x6Lk0ajK03poWOmyFpbu4uc | string | 是 | - |

**认证方式**

> 继承父级

**响应示例**

* 成功(200)

```javascript
{
	"code": 200,
	"msg": "领取成功",
	"data": []
}
```

| 参数名 | 示例值 | 参数类型 | 参数描述 |
| --- | --- | ---- | ---- |
| code | 200 | number | - |
| msg | success | string | 错误信息 |
| data | - | object | - |
| data.user_sum | 0 | number | 总会员人数 |
| data.user_youxiao | 0 | number | 总有效会员 |
| data.dailingqu | 0 | number | 待领取金额 |
| data.zuidi | 1 | string | 最低金额为有效会员 |
| data.user_max | 0 | number | 下一级>= |
| data.user_amount | 0 | number | 下一级可领取金额 |

* 失败(200)

```javascript
{
	"code": 0,
	"msg": "暂无可领取的红利"
}
```

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| lang | CN | string | 是 | - |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjYwMDAwL2FwaS91c2VyL2xvZ2luIiwiaWF0IjoxNzY4OTAzMDA5LCJleHAiOjE3NzE0OTUwMDksIm5iZiI6MTc2ODkwMzAwOSwianRpIjoiRmFMaGpKckFxMDNxUjF5QyIsInN1YiI6IjE3IiwicHJ2IjoiODY2NWFlOTc3NWNmMjZmNmI4ZTQ5NmY4NmZhNTM2ZDY4ZGQ3MTgxOCJ9.-_9KLJL8toCjUzB51oS_x6Lk0ajK03poWOmyFpbu4uc | string | 是 | - |

**Query**

#### 其他接口

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2026-03-23 12:35:40

> 更新时间: 2026-03-23 12:35:40

```text
暂无描述
```

**目录Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| 暂无参数 |

**目录Query参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| 暂无参数 |

**目录Body参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| 暂无参数 |

**目录认证信息**

> 继承父级

**Query**

##### 今日收益

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2026-03-23 12:36:22

> 更新时间: 2026-03-23 14:36:26

```text
暂无描述
```

**接口状态**

> 已完成

**接口URL**

> http://45.200.16.18:60000/api/day_revenue/getlist

**请求方式**

> POST

**Content-Type**

> none

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjYwMDAwL2FwaS91c2VyL2xvZ2luIiwiaWF0IjoxNzc0MjQxOTI0LCJleHAiOjE3NzY4MzM5MjQsIm5iZiI6MTc3NDI0MTkyNCwianRpIjoiVTF2ZlpOZmlrYzlvaDR6dCIsInN1YiI6IjgxNyIsInBydiI6Ijg2NjVhZTk3NzVjZjI2ZjZiOGU0OTZmODZmYTUzNmQ2OGRkNzE4MTgifQ.p9c1Ub0zHn847ym6rBJ-xl9EqDeqswbt_4rcxvyjscA | string | 是 | - |
| lang | CN | string | 是 | - |

**认证方式**

> 继承父级

**响应示例**

* 成功(200)

```javascript
{
	"code": 200,
	"msg": "success",
	"data": {
		"day_netAmount": 0,
		"day_bet_count": 0,
		"day_zongfs": 0,
		"day_lingqu": 0,
		"day_weiling": 0
	}
}
```

| 参数名 | 示例值 | 参数类型 | 参数描述 |
| --- | --- | ---- | ---- |
| code | 200 | number | - |
| msg | success | string | - |
| data | - | object | - |
| data.day_netAmount | 0 | number | 今日总盈亏 |
| data.day_bet_count | 0 | number | 今日投注总条数 |
| data.day_zongfs | 0 | number | 今日总反水 |
| data.day_lingqu | 0 | number | 今日已领取 |
| data.day_weiling | 0 | number | 今日未领取 |

* 失败(404)

```javascript
{
	"code": 200,
	"msg": "success",
	"data": {
		"data": [],
		"current_page": 1,
		"total": 0,
		"lastPage": 0
	}
}
```

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjYwMDAwL2FwaS91c2VyL2xvZ2luIiwiaWF0IjoxNzc0MjQxOTI0LCJleHAiOjE3NzY4MzM5MjQsIm5iZiI6MTc3NDI0MTkyNCwianRpIjoiVTF2ZlpOZmlrYzlvaDR6dCIsInN1YiI6IjgxNyIsInBydiI6Ijg2NjVhZTk3NzVjZjI2ZjZiOGU0OTZmODZmYTUzNmQ2OGRkNzE4MTgifQ.p9c1Ub0zHn847ym6rBJ-xl9EqDeqswbt_4rcxvyjscA | string | 是 | - |
| lang | CN | string | 是 | - |

**Query**

##### 获取会员实时余额，主+接口

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2026-03-29 13:48:22

> 更新时间: 2026-03-29 13:52:03

**该接口建议30秒以上调用一次**

**接口状态**

> 已完成

**接口URL**

> http://45.200.16.18:60000/api/user/balance

**请求方式**

> POST

**Content-Type**

> none

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjYwMDAwL2FwaS91c2VyL2xvZ2luIiwiaWF0IjoxNzc0NzYzMzM5LCJleHAiOjE3NzczNTUzMzksIm5iZiI6MTc3NDc2MzMzOSwianRpIjoiaFpCOGFkdG55S0RjNVlKYiIsInN1YiI6IjgxNyIsInBydiI6Ijg2NjVhZTk3NzVjZjI2ZjZiOGU0OTZmODZmYTUzNmQ2OGRkNzE4MTgifQ.P4ImxLuvgKsYfLosL4LCUHnF5cpMo9B1xqpayNC09Es | string | 是 | - |
| lang | CN | string | 是 | - |

**认证方式**

> 继承父级

**响应示例**

* 成功(200)

```javascript
{
	"code": 200,
	"msg": "success",
	"data": {
		"balance": 0
	}
}
```

| 参数名 | 示例值 | 参数类型 | 参数描述 |
| --- | --- | ---- | ---- |
| code | 200 | number | - |
| msg | success | string | - |
| data | - | object | - |
| data.balance | 0 | number | 总额度 |

* 失败(404)

```javascript
{
	"code": 200,
	"msg": "success",
	"data": {
		"data": [],
		"current_page": 1,
		"total": 0,
		"lastPage": 0
	}
}
```

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjYwMDAwL2FwaS91c2VyL2xvZ2luIiwiaWF0IjoxNzc0NzYzMzM5LCJleHAiOjE3NzczNTUzMzksIm5iZiI6MTc3NDc2MzMzOSwianRpIjoiaFpCOGFkdG55S0RjNVlKYiIsInN1YiI6IjgxNyIsInBydiI6Ijg2NjVhZTk3NzVjZjI2ZjZiOGU0OTZmODZmYTUzNmQ2OGRkNzE4MTgifQ.P4ImxLuvgKsYfLosL4LCUHnF5cpMo9B1xqpayNC09Es | string | 是 | - |
| lang | CN | string | 是 | - |

**Query**

#### 修改密码

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2026-04-10 16:42:18

> 更新时间: 2026-04-10 16:42:18

```text
暂无描述
```

**目录Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| 暂无参数 |

**目录Query参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| 暂无参数 |

**目录Body参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| 暂无参数 |

**目录认证信息**

> 继承父级

**Query**

##### 修改密码

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2026-04-10 16:42:18

> 更新时间: 2026-04-10 16:42:33

```text
暂无描述
```

**接口状态**

> 已完成

**接口URL**

> http://45.200.16.18:60000/api/token/repass

**请求方式**

> POST

**Content-Type**

> json

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjY1NTM1L20vdXNlci9sb2dpbiIsImlhdCI6MTczNDQwNTM1NiwiZXhwIjoxNzM2OTk3MzU2LCJuYmYiOjE3MzQ0MDUzNTYsImp0aSI6Im5tbTZZb01Hd3R2QkEwN1oiLCJzdWIiOiI2NTYiLCJwcnYiOiI4NjY1YWU5Nzc1Y2YyNmY2YjhlNDk2Zjg2ZmE1MzZkNjhkZDcxODE4In0.G3Kxsn_MvArExhh-6CSwmyh-IbJ6EcX7cYzdgn_ISu8 | string | 是 | - |
| lang | CN | string | 是 | - |

**请求Body参数**

```javascript
{
    "currentPass": "dd46461",
    "newPass": 456789,
    "confirmpass": 456789
}
```

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| currentPass | 123456 | number | 是 | 当前密码 |
| newPass | 456789 | number | 是 | 新密码 |
| phoconfirmpassne | 456789 | number | 是 | 确认新密码 |

**认证方式**

> 继承父级

**响应示例**

* 成功(200)

```javascript
{
	"code": 200,
	"msg": "修改密码成功",
	"data": []
}
```

* 失败(404)

```javascript
{
	"code": 0,
	"msg": "当前密码错误"
}
```

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE4OjY1NTM1L20vdXNlci9sb2dpbiIsImlhdCI6MTczNDQwNTM1NiwiZXhwIjoxNzM2OTk3MzU2LCJuYmYiOjE3MzQ0MDUzNTYsImp0aSI6Im5tbTZZb01Hd3R2QkEwN1oiLCJzdWIiOiI2NTYiLCJwcnYiOiI4NjY1YWU5Nzc1Y2YyNmY2YjhlNDk2Zjg2ZmE1MzZkNjhkZDcxODE4In0.G3Kxsn_MvArExhh-6CSwmyh-IbJ6EcX7cYzdgn_ISu8 | string | 是 | - |
| lang | CN | string | 是 | - |

**Query**

### 单页数据

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-10-08 22:53:15

> 更新时间: 2025-10-15 18:04:48

```text
暂无描述
```

**目录Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| 暂无参数 |

**目录Query参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| 暂无参数 |

**目录Body参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| 暂无参数 |

**目录认证信息**

> 继承父级

**Query**

#### 获取单页分类

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-10-08 23:07:19

> 更新时间: 2025-10-10 17:50:06

```text
暂无描述
```

**接口状态**

> 已完成

**接口URL**

> http://45.200.16.18:60000/api/single/class

**请求方式**

> POST

**Content-Type**

> json

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| lang | CN | string | 是 | - |

**请求Body参数**

```javascript
暂无数据
```

**认证方式**

> 继承父级

**响应示例**

* 成功(200)

```javascript
{
	"code": 200,
	"msg": "success",
	"data": [
		{
			"id": 1,
			"title": "ok"
		},
		{
			"id": 2,
			"title": "ok"
		},
		{
			"id": 3,
			"title": "ok"
		}
	]
}
```

| 参数名 | 示例值 | 参数类型 | 参数描述 |
| --- | --- | ---- | ---- |
| code | 200 | number | - |
| msg | success | string | - |
| data | - | object | - |
| data.data | - | array | - |
| data.data.id | 1 | number | 数据ID |
| data.data.title | 111 | string | 游戏名称 |
| data.data.img | - | string | 游戏图片 |
| data.current_page | 1 | number | - |
| data.total | 1 | number | - |
| data.lastPage | 1 | number | - |
| data.data.favorites | false | boolean | 是否收藏：true是，false否 |

* 失败(200)

```javascript
{
	"code": 200,
	"msg": "success",
	"data": [
		{
			"id": 1,
			"title": "ok"
		},
		{
			"id": 2,
			"title": "ok"
		},
		{
			"id": 3,
			"title": "ok"
		}
	]
}
```

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| lang | CN | string | 是 | - |

**Query**

#### 获取单页详情

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-10-08 23:27:07

> 更新时间: 2025-10-08 23:34:04

```text
暂无描述
```

**接口状态**

> 已完成

**接口URL**

> http://45.200.16.18:60000/api/single/getlist

**请求方式**

> POST

**Content-Type**

> json

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| lang | CN | string | 是 | - |

**请求Body参数**

```javascript
{
    "id": 1
}
```

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| id | 1 | number | 是 | 单页分类ID |

**认证方式**

> 继承父级

**响应示例**

* 成功(200)

```javascript
{
	"code": 200,
	"msg": "success",
	"data": {
		"data": "ok"
	}
}
```

| 参数名 | 示例值 | 参数类型 | 参数描述 |
| --- | --- | ---- | ---- |
| code | 200 | number | - |
| msg | success | string | - |
| data | - | object | - |
| data.data | - | array | - |
| data.data.id | 1 | number | 数据ID |
| data.data.title | 111 | string | 游戏名称 |
| data.data.img | - | string | 游戏图片 |
| data.current_page | 1 | number | - |
| data.total | 1 | number | - |
| data.lastPage | 1 | number | - |
| data.data.favorites | false | boolean | 是否收藏：true是，false否 |

* 失败(200)

```javascript
{
	"code": 200,
	"msg": "success",
	"data": {
		"data": "ok"
	}
}
```

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| lang | CN | string | 是 | - |

**Query**

### 上传图片

> 创建人: qq123456

> 更新人: qq123456

> 创建时间: 2025-10-07 19:18:31

> 更新时间: 2025-10-26 00:35:02

```text
暂无描述
```

**接口状态**

> 已完成

**接口URL**

> http://45.200.16.173:65535/api/img/save

**请求方式**

> POST

**Content-Type**

> form-data

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE3Mzo2NTUzNS9hZG1pbl9iYXNlL2xvZ2luIiwiaWF0IjoxNzIzNTI4MDU1LCJleHAiOjE3MjYxMjAwNTUsIm5iZiI6MTcyMzUyODA1NSwianRpIjoiWTdJRHZpeHNaRkRvbzZJWiIsInN1YiI6IjEiLCJwcnYiOiIyM2JkNWM4OTQ5ZjYwMGFkYjM5ZTcwMWM0MDA4NzJkYjdhNTk3NmY3In0.QzqTX0VrUrENuont9H_cHEQ7uoz0wMsI8t0Dj-1SxZk | string | 是 | - |

**请求Body参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| file | C:\Users\Administrator\Desktop\app.png | file | 是 | - |
| name | banner | string | 是 | 图片类型，哪个部位的图片 |

**认证方式**

> 继承父级

**响应示例**

* 成功(200)

```javascript
{
	"code": 200,
	"msg": "success",
	"data": {
		"data": {
			"path": "/uploads/images/banner/202408/13/4ed9864c02cf09460a6a93693a719cf6.png",
			"url": "http://localhost/uploads/images/banner/202408/13/4ed9864c02cf09460a6a93693a719cf6.png"
		}
	}
}
```

* 失败(200)

```javascript
暂无数据
```

**请求Header参数**

| 参数名 | 示例值 | 参数类型 | 是否必填 | 参数描述 |
| --- | --- | ---- | ---- | ---- |
| Authorization | bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vNDUuMjAwLjE2LjE3Mzo2NTUzNS9hZG1pbl9iYXNlL2xvZ2luIiwiaWF0IjoxNzIzNTI4MDU1LCJleHAiOjE3MjYxMjAwNTUsIm5iZiI6MTcyMzUyODA1NSwianRpIjoiWTdJRHZpeHNaRkRvbzZJWiIsInN1YiI6IjEiLCJwcnYiOiIyM2JkNWM4OTQ5ZjYwMGFkYjM5ZTcwMWM0MDA4NzJkYjdhNTk3NmY3In0.QzqTX0VrUrENuont9H_cHEQ7uoz0wMsI8t0Dj-1SxZk | string | 是 | - |

**Query**
