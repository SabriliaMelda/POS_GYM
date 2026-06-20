package database

import (
	"database/sql"
	"fmt"
	"time"

	mysql "github.com/go-sql-driver/mysql"

	"pos-gym/backend/internal/config"
)

func Open(cfg config.Config) (*sql.DB, error) {
	mysqlConfig := mysql.Config{
		User:      cfg.DBUser,
		Passwd:    cfg.DBPassword,
		Net:       "tcp",
		Addr:      fmt.Sprintf("%s:%s", cfg.DBHost, cfg.DBPort),
		DBName:    cfg.DBName,
		ParseTime: true,
		Loc:       time.Local,
		Params: map[string]string{
			"charset": "utf8mb4",
		},
	}

	db, err := sql.Open("mysql", mysqlConfig.FormatDSN())
	if err != nil {
		return nil, err
	}

	db.SetMaxOpenConns(20)
	db.SetMaxIdleConns(10)
	db.SetConnMaxLifetime(30 * time.Minute)

	return db, nil
}