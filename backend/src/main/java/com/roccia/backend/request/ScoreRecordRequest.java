package com.roccia.backend.request;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class ScoreRecordRequest {
    private String teamName;
    private String userName;
    private int sector;
    private int score;
}