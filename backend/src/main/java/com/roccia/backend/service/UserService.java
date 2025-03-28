package com.roccia.backend.service;

import com.roccia.backend.entity.User;
import com.roccia.backend.repository.UserRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;

    public User loginOrCreateUser(String teamName, String userName) {
        return userRepository.findByTeamNameAndUserName(teamName, userName)
                .orElseGet(() -> userRepository.save(User.builder()
                        .teamName(teamName)
                        .userName(userName)
                        .build()));
    }
    @Transactional
    public void logout(String teamName, String userName) {
        userRepository.deleteByTeamNameAndUserName(teamName, userName);
    }

    public Optional<User> find(String teamName, String userName) {
        return userRepository.findByTeamNameAndUserName(teamName, userName);
    }
}