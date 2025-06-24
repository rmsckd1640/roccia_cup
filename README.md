# Roccia Cup 🧗‍♂️  
클라이밍 대회 점수 계산 및 실시간 랭킹 제공 앱

---

## 📌 프로젝트 설명

Roccia Cup은 클라이밍 동아리 대회에서의 점수 집계와 랭킹 계산을 자동화하기 위해 개발된 웹 애플리케이션입니다.  
기존 수기 방식의 불편함과 오류를 개선하고, 운영진과 참가자 모두가 실시간으로 점수를 확인할 수 있는 환경을 제공하고자 제작하였습니다.

편입 이후, 실제로 개발이 어떻게 돌아가는지 직접 체감하고자  
기획부터 백엔드, 프론트엔드, 배포까지 전 과정을 혼자서 처음부터 부딪혀가며 구현한 프로젝트입니다.

- 실시간 점수 입력 및 팀 랭킹 조회
- 사용자 정보 수정 기능
- 중복 입력 방지 로직  
- 2025년 5월 동아리 대회에 실제 적용

---

## 🛠 기술 스택

### 🖥 Frontend
<div align="left">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white"/>
</div>

### ⚙️ Backend
<div align="left">
  <img src="https://img.shields.io/badge/SpringBoot-6DB33F?style=for-the-badge&logo=springboot&logoColor=white"/>
</div>

### 🛢 Database
<div align="left">
  <img src="https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white"/>
</div>

### ☁️ Infrastructure
<div align="left">
  <img src="https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white"/>
  <img src="https://img.shields.io/badge/Nginx-009639?style=for-the-badge&logo=nginx&logoColor=white"/>
  <img src="https://img.shields.io/badge/AWS EC2-FF9900?style=for-the-badge&logo=amazon-aws&logoColor=white"/>
  <img src="https://img.shields.io/badge/Route 53-232F3E?style=for-the-badge&logo=amazon-aws&logoColor=white"/>
</div>



---

## 🖥 시스템 아키텍처

![server architecture](https://github.com/user-attachments/assets/66c8cbc1-9173-473d-a69d-e47fc5f8ae1f)

---

## 🗃 ERD

<img width="342" alt="roccia_cup ERD" src="https://github.com/user-attachments/assets/be79564a-26f8-451e-b0eb-774050e2551d" />

---

## 🧠 회고

이번 프로젝트는 클라이밍 대회 운영이라는 실제 목적을 바탕으로, 기획부터 개발, 배포까지 전 과정을 혼자 주도하여 진행한 나의 첫 프로젝트였다.  
단순히 코드를 작성하는 수준을 넘어, 개발이 실제로 어떻게 돌아가는지를 체험할 수 있었으며, 결과보다 그 과정에서 더 많은 것을 배울 수 있었다.

처음에는 기능 구현에 집중하였으나, 진행하면서 생각보다 신경 써야 할 요소가 많다는 것을 느꼈다.  
예를 들어 메모리 사용량 관리, 동시 요청 처리, 서버 보안 설정, 예외 처리 및 에러 핸들링 구조 등은 이번에 충분히 고려하지 못한 부분이었다.

이러한 시행착오를 통해 단순히 동작하는 코드를 넘어서, 안정적이고 신뢰할 수 있는 서비스를 만들기 위해 어떤 부분을 신경 써야 하는지 구체적으로 알게 되었다.

다음 프로젝트에서는 이번 경험을 바탕으로, 더 다양한 기능을 포함하고 보안과 성능, 구조적인 완성도까지 고려한 개발을 해보고자 한다.
