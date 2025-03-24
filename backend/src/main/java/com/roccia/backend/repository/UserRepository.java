package com.roccia.backend.repository;

import com.roccia.backend.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Long> {

    Optional<User> findByTeamNameAndUserName(String teamName, String userName);

    void deleteByTeamNameAndUserName(String teamName, String userName);

    boolean existsByTeamNameAndUserName(String teamName, String userName);
}