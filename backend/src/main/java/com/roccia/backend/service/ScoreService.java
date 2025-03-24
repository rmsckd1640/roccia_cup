package com.roccia.backend.service;

import com.roccia.backend.entity.ScoreRecord;
import com.roccia.backend.entity.User;
import com.roccia.backend.repository.ScoreRecordRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class ScoreService {

    private final ScoreRecordRepository scoreRecordRepository;

    public ScoreRecord submitScore(User user, String sector, int score) {
        if (scoreRecordRepository.findByUserAndSector(user, sector).isPresent()) {
            throw new IllegalArgumentException("이미 이 섹터에 점수를 입력했습니다.");
        }

        return scoreRecordRepository.save(ScoreRecord.builder()
                .user(user)
                .sector(sector)
                .score(score)
                .build());
    }

    public List<ScoreRecord> getScores(User user) {
        return scoreRecordRepository.findByUser(user);
    }

    public void deleteScore(User user, String sector) {
        Optional<ScoreRecord> scoreOpt = scoreRecordRepository.findByUserAndSector(user, sector);
        scoreOpt.ifPresent(scoreRecordRepository::delete);
    }

    public void deleteAllByUser(User user) {
        scoreRecordRepository.deleteByUser(user);
    }
}