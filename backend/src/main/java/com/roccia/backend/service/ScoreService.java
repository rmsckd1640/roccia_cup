package com.roccia.backend.service;

import com.roccia.backend.entity.ScoreRecord;
import com.roccia.backend.entity.User;
import com.roccia.backend.repository.ScoreRecordRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class ScoreService {

    private final ScoreRecordRepository scoreRecordRepository;

    public ScoreRecord submitScore(User user, int sector, int score) {
        if (sector == 99 && scoreRecordRepository.existsByUser_TeamNameAndSector(user.getTeamName(), 99)) {
            throw new IllegalArgumentException("이미 이 팀은 지구력 점수를 입력했습니다.");
        }

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

    @Transactional
    public void deleteScore(User user, int sector) {
        Optional<ScoreRecord> scoreOpt = scoreRecordRepository.findByUserAndSector(user, sector);
        scoreOpt.ifPresent(scoreRecordRepository::delete);
    }

    public void deleteAllByUser(User user) {
        scoreRecordRepository.deleteByUser(user);
    }
}