package com.roccia.backend.controller;

import com.roccia.backend.entity.ScoreRecord;
import com.roccia.backend.entity.User;
import com.roccia.backend.service.ScoreService;
import com.roccia.backend.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/scores")
@RequiredArgsConstructor
public class ScoreController {

    private final ScoreService scoreService;
    private final UserService userService;

    // 점수 제출
    @PostMapping("/submit")
    public ResponseEntity<?> submitScore(@RequestParam String teamName,
                                         @RequestParam String userName,
                                         @RequestParam int sector,
                                         @RequestParam int score) {

        User user = userService.find(teamName, userName)
                .orElseThrow(() -> new RuntimeException("사용자가 존재하지 않습니다."));

        ScoreRecord saved = scoreService.submitScore(user, sector, score);
        return ResponseEntity.ok(saved);
    }

    // 사용자 점수 조회
    @GetMapping("/user")
    public ResponseEntity<List<ScoreRecord>> getUserScores(@RequestParam String teamName,
                                                           @RequestParam String userName) {
        User user = userService.find(teamName, userName)
                .orElseThrow(() -> new RuntimeException("사용자가 존재하지 않습니다."));

        return ResponseEntity.ok(scoreService.getScores(user));
    }

    // 특정 섹터 점수 삭제
    @DeleteMapping("/delete")
    public ResponseEntity<Void> deleteScore(@RequestParam String teamName,
                                            @RequestParam String userName,
                                            @RequestParam int sector) {
        User user = userService.find(teamName, userName)
                .orElseThrow(() -> new RuntimeException("사용자가 존재하지 않습니다."));

        scoreService.deleteScore(user, sector);
        return ResponseEntity.noContent().build();
    }
}