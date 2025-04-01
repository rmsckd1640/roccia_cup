package com.roccia.backend.controller;

import com.roccia.backend.entity.ScoreRecord;
import com.roccia.backend.entity.User;
import com.roccia.backend.repository.ScoreRecordRepository;
import com.roccia.backend.repository.UserRepository;
import com.roccia.backend.request.UserRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/rankings")
@RequiredArgsConstructor
public class RankingController {

    private final UserRepository userRepository;
    private final ScoreRecordRepository scoreRecordRepository;

    @PostMapping(produces = "application/json; charset=UTF-8")
    public ResponseEntity<List<Map<String, Object>>> getTeamRankings(@RequestBody UserRequest request) {
        List<User> users = userRepository.findAll();
        Map<String, Integer> teamScores = new HashMap<>();

        for (User user : users) {
            int total = scoreRecordRepository.findByUser(user).stream()
                    .mapToInt(ScoreRecord::getScore)
                    .sum();
            teamScores.merge(user.getTeamName(), total, Integer::sum);
        }

        // 정렬
        List<Map<String, Object>> rankings = teamScores.entrySet().stream()
                .sorted(Map.Entry.<String, Integer>comparingByValue().reversed())
                .map(entry -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("teamName", entry.getKey());
                    map.put("totalScore", entry.getValue());
                    return map;
                })
                .collect(Collectors.toList());

        return ResponseEntity.ok(rankings);
    }
}