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
        User user = userService.loginOrCreateUser(request.getTeamName(), request.getUserName(), request.getRole());
        return ResponseEntity.ok(user);
    }

    @PatchMapping("/update")
    public ResponseEntity<User> updateUser(@RequestBody UserRequest request) {
        User updatedUser = userService.updateUser(request);  // 여기에 try-catch 있으면 안됨!
        return ResponseEntity.ok(updatedUser);
    }




}