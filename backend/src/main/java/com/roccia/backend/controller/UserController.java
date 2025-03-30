package com.roccia.backend.controller;

import com.roccia.backend.entity.User;
import com.roccia.backend.request.UserRequest;
import com.roccia.backend.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    // 로그인 (있으면 반환, 없으면 생성)
    @PostMapping("/login")
    public ResponseEntity<User> login(@RequestBody UserRequest request) {
        User user = userService.loginOrCreateUser(request.getTeamName(), request.getUserName());
        return ResponseEntity.ok(user);
    }

    // 로그아웃 (유저 + 점수 모두 삭제)
    @DeleteMapping("/logout")
    public ResponseEntity<Void> logout(@RequestBody UserRequest request) {
        userService.logout(request.getTeamName(), request.getUserName());
        return ResponseEntity.noContent().build();
    }
}