package com.roccia.backend.service;

import com.roccia.backend.entity.User;
import com.roccia.backend.repository.UserRepository;
import com.roccia.backend.request.UserRequest;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;


import java.util.Optional;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;

    public User loginOrCreateUser(String teamName, String userName, String role) {
        return userRepository.findByTeamNameAndUserName(teamName, userName)
                .orElseGet(() -> userRepository.save(User.builder()
                        .teamName(teamName)
                        .userName(userName)
                        .role(role)
                        .build()));
    }

    @Transactional
    public User updateUser(UserRequest request) {
        User user = userRepository.findByTeamNameAndUserName(
                        request.getTeamName(), request.getUserName())
                .orElseThrow(() -> new RuntimeException("User not found"));

        user.setTeamName(request.getNewTeamName());
        user.setUserName(request.getNewUserName());

        if (request.getNewRole() != null && !request.getNewRole().isBlank()) {
            user.setRole(request.getNewRole());
        }

        return userRepository.save(user);
    }


    public Optional<User> find(String teamName, String userName) {
        return userRepository.findByTeamNameAndUserName(teamName, userName);
    }

}