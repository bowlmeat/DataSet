# DataSet
## 数据说明
- 数据源
  - smartbugs-curated数据，它的目录就是按漏洞分类组织 DASP-10

- 目录结构
  - 爬虫，从[etherscan.io](etherscan.io)中爬取合约。==爬取合约可能不含漏洞信息==
  - 漏洞合约
    - 按漏洞类型分类。 ==包括 1.手动注入 2.真实合约==

- 漏洞类别
  - 分类标准：==这里直接写漏洞名称==
    1. SWC 
    2. DASP-10
    3. SP

- 漏洞分类
    | ID          | 漏洞         |
    | ----------- | ----------- |
    | Paragraph   | Text        |

- ⚠️注：
  - etherscan.io合约不一定有漏洞
  - 合约版本低，都在0.4左右

## 类型映射
form_2下映射到DASP-10分类方法：
- Overflow-Underflow -> Arithmetic
- Re-entrancy -> Reentrancy
- TOD (Transaction-Ordering Dependence) -> Front Running
- Timestamp-Dependency -> Time Manipulation
- Unchecked-Send -> Unchecked Low Level Calls
- Unhandled-Exceptions -> Other
- tx.origin -> Access Control

## 指令
- 查找文件数目
  - 递归统计所有文件
    ```
    find . -type f -name "*.sol" | wc -l
    ```
  - 当前目录
    ```
    find . -maxdepth 1 -type f -name "*.sol" | wc -l
    ```
  - solidity文件数目情况
    `form_1`: 212, `form_2`: 350 