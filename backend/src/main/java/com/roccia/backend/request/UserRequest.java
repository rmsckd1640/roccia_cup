package com.roccia.backend.request;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class UserRequest {
    private String teamName;
    private String userName;
    private String newTeamName;
    private String newUserName;
    private String role; // 옵션
    private String newRole; //역할 수정 시 사용
}