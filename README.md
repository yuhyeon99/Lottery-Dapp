# 김유현

# Lottery Dapp 프로젝트
`Web3.js`, `Truffle`, `ganache-cli`, `Solidity`, `metamask`, `react` 등을 이용해서 확률 어플리케이션을 구현한 프로젝트 「Lottery Dapp」 입니다.

<br>

## 개발자의 GitHub 주소

<table>
  <tr> 
    <td align="center"><a href="https://github.com/yuhyeon99"><img src="https://avatars.githubusercontent.com/u/83055700?s=96&v=4" width="100px;" alt=""/><br /><sub><b>김유현</b></sub></a><br /><a href="https://github.com/yuhyeon99" title="Code">🏠</a>
    </td>
  </tr>
</table>

> "어제 자신을 넘어 더욱 성장을 추구하는 개발자 김유현이라고 합니다."

<br>

## 실행 및 테스트
첫번째 터미널
```
$ cd lottery-smart-contract
$ ganache-cli -d -m tutorial
```

두번째 터미널
```
$ cd lottery-smart-contract
$ npm install
$ truffle test test/lottery.test.js
```

# 🔍 목차

> 1. GitHub 관리 전략
> 2. 프로젝트
>    1. 개요
>    2. 개념
>    3. 신중하게 생각한 부분
>       - 테스트코드
> 3. 개발 환경
>    1. 프레임워크
>    2. 데이터베이스
> 4. 힘들었던 일
> 5. 사용 기술
> 6. 자기 평가
> 7.  조언하고 싶은 포인트

<br>



# 1. GitHub 관리 전략

## 1.1. :pushpin: Commit Convention

|   [Type]    |             설명              |                       예                       |
| :---------: | :---------------------------: | :--------------------------------------------: |
|     feat     |  기능 추가 :heavy_plus_sign:   |           "feat : TodoList add 기능 추가"           |
|     fix     |        버그 수정 :bug:         | "fix : 이미지 업로드 버그 수정" |
|   modify    |  코드 타이포 수정 :zap:   |      "modify : 날씨 API 서비스 수정"      |
|  refactor   |  코드 구조 변경 :pencil2:   |   "refactor : 입력 코드와 리스트 코드 분리"    |
| enhancement | UI 디자인 변경  (CSS) :art: |      "enhancement : 날씨 display UI 수정"      |
| Deployment  |                               |                                                |

<br>

_____


## 1.2. GIt Branch관리

```
main -- develop -- add/#1   
                \_ add/#2     
```

* `main` : 배포되는 기본 버전
* `develop` : 개발 브랜치
* 기능 개발 브랜치는 develop 브랜치에서 생성되어 개발을 진행합니다.


<br>


# 2. 프로젝트

## 2.1. 개요

- 프로젝트 이름: Lottery Dapp
- 의미: 배팅해서 팟머니를 걸고 스마트 컨트랙트를 통해 생성된 해쉬값의 값을 맞추는 Dapp 프로젝트「Lottery Dapp」 입니다.


## 2.2. 개념

본인이 만든 transition을 통해 생성된 block의 blockhash 값의 일부분을 맞추면 Pot머니를 가져가고 못 맞추면 Pot머니를 못 가져가는 Lottery game 이며 프론트엔드에선 ReactJs를 통해 구현하고 Solidity 를 통해 스마트 컨트렉트를 구현합니다. Web3js를 활용해서 메타마스크와 연동하여 거래를 진행합니다.

### 특징

1. 사용자는 본인이 만든 transition을 통해 생성된 block의 blockhash 값의 일부분을 맞추면 Pot머니를 가져가고 못 맞추면 Pot머니를 못 가져갑니다.
2. 메타마스크를 통해 계약(거래)를 할 수 있습니다. 



<br>

## 2.3. 주의깊게 생각한 부분(테스트 코드)

- ### 테스트 코드
    - 테스트 코드 작성방법에 대한 고민
    - unit 테스트: 도메인 모델과 비즈니스 로직을 테스트, 작은 단위의 코드 및 알고리즘 테스트 채택


# 3. 개발 환경

## 3.1. 프레임워크

1. Front
   - React.js  `18.2.0`


## 3.2. 라이브러리

1. Truffle
2. Solidity
3. Web3.js
4. ganache-cli
5. React.js

<br>

## 개발 환경

OS: Window

IDE: Visual Studio Code


<br>

------


# 4. 힘들었던 일

1. 버전 차이로 인한 스마트 컨트렉트 거래 과정 중 오류
  - ![image](https://github.com/yuhyeon99/Lottery-Dapp/assets/83055700/82efbe1f-18f1-49cc-8248-39d2ab08b23f)

   ### 원인

   1.아래 오류 사진을 확인해보니 트랜잭션 과정 중 생긴 오류라는데 구체적인 오류를 확인할 수 없었고 비슷한 오류로는 가스비 설정이 있는      데 그 경우에는 해당되지 않았습니다.
      - ![image](https://github.com/yuhyeon99/Lottery-Dapp/assets/83055700/f016d9a3-796c-4368-bb07-0dd099d4aeae)

   ### 해결중

   1. 버전을 수정해서 solcjs 컴파일 및 코드 수정 할 예정.

## 5. 사용기술（Skill）




`Truffle` `ganache-cli` `Solidity` `React.js` `Web3.js`

<br>

# 6. 자기 평가
구 버전으로 작업했지만 Solidity를 통한 테스트 코드는 모두 작동했고 스마트 컨트랙트와의 연동 및 ETH 충전까지는 잘 진행되었지만 이후 직접적인 거래에서 해결하지 못한 오류가 발생해 아쉬웠습니다. 추후에 해당 부분 트러블 슈팅 할 계획입니다.
낯선 개발언어인 만큼 자주 접하고 부딪혀서 해결해내는게 목표입니다. 

<br>



<br>

# 7. 조언해 주었으면 하는 점

미흡했던 부분이나 비효율적인 코드 또는 프로젝트 구조 부분에 대해서 조언해주셨으면 합니다.