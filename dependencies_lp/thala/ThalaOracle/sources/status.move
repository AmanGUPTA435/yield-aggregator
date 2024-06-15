module thala_oracle::status {
    const ENUM_NORMAL_STATUS: u8 = 100;
    const ENUM_STALE_STATUS: u8 = 101;
    const ENUM_BROKEN_STATUS: u8 = 102;
    
    public fun normal_status(): u8 {
        ENUM_NORMAL_STATUS
    }

    public fun stale_status(): u8 {
        ENUM_STALE_STATUS
    }

    public fun broken_status(): u8 {
        ENUM_BROKEN_STATUS
    }

    public fun is_normal_status(status: u8): bool {
        ENUM_NORMAL_STATUS == status
    }

    public fun is_stale_status(status: u8): bool {
        ENUM_STALE_STATUS == status
    }

    public fun is_broken_status(status: u8): bool {
        ENUM_BROKEN_STATUS == status
    }

    public fun check_freshness(seconds_elasped: u64, staleness_seconds: u64, broken_seconds: u64): u8 {
        if (seconds_elasped >= broken_seconds) {
            ENUM_BROKEN_STATUS
        } else if (seconds_elasped >= staleness_seconds) {
            ENUM_STALE_STATUS
        } else {
            ENUM_NORMAL_STATUS
        }
    }
}