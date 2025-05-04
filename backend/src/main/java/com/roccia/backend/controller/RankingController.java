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

        Map<String, Integer> teamScoreSum = new HashMap<>();
        Map<String, Integer> teamMemberCount = new HashMap<>();

        for (User user : users) {
            String teamName = user.getTeamName();

            // 유저의 점수 중에서 지구력(99) 제외
            List<ScoreRecord> scores = scoreRecordRepository.findByUser(user).stream()
                    .filter(score -> score.getSector() != 99)
                    .collect(Collectors.toList());

            int sum = scores.stream().mapToInt(ScoreRecord::getScore).sum();

            // 점수는 유효한 점수만 합산
            teamScoreSum.merge(teamName, sum, Integer::sum);

            // 무조건 팀 인원수 1 증가 (점수가 없어도)
            teamMemberCount.merge(teamName, 1, Integer::sum);
        }

        // 평균 계산 및 정렬
        Set<String> allTeams = teamMemberCount.keySet();

        List<Map<String, Object>> rankings = allTeams.stream()
                .map(team -> {
                    int sum = teamScoreSum.getOrDefault(team, 0);
                    int count = teamMemberCount.getOrDefault(team, 1); // 항상 >=1
                    double avg = (double) sum / count;

                    Map<String, Object> map = new HashMap<>();
                    map.put("teamName", team);
                    map.put("averageScore", avg);
                    return map;
                })
                .sorted((a, b) -> Double.compare((double) b.get("averageScore"), (double) a.get("averageScore")))
                .collect(Collectors.toList());

        return ResponseEntity.ok(rankings);
    }


}