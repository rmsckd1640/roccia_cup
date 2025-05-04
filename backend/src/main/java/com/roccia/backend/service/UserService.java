package com.roccia.backend.service;

import com.roccia.backend.entity.User;
import com.roccia.backend.repository.UserRepository;
import com.roccia.backend.request.UserRequest;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.http.HttpStatus;


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
        User currentUser = userRepository.findByTeamNameAndUserName(
                        request.getTeamName(), request.getUserName())
                .orElseThrow(() -> new RuntimeException("User not found"));

        // 본인이 아닌데 같은 팀명 + 이름인 유저가 이미 존재할 경우 예외 처리
        Optional<User> existing = userRepository.findByTeamNameAndUserName(
                request.getNewTeamName(), request.getNewUserName());

        if (existing.isPresent() && !existing.get().getId().equals(currentUser.getId())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "이미 존재하는 팀명과 이름입니다.");
        }

        // 수정 진행
        currentUser.setTeamName(request.getNewTeamName());
        currentUser.setUserName(request.getNewUserName());

        if (request.getNewRole() != null && !request.getNewRole().isBlank()) {
            currentUser.setRole(request.getNewRole());
        }

        return userRepository.save(currentUser);
    }



    public Optional<User> find(String teamName, String userName) {
        return userRepository.findByTeamNameAndUserName(teamName, userName);
    }

    public boolean existsByTeamNameAndUserName(String teamName, String userName) {
        return userRepository.findByTeamNameAndUserName(teamName, userName).isPresent();
    }


}