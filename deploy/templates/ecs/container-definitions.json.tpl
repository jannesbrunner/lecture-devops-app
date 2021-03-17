[
    {
        "name": "server",
        "image": "${app_image}",
        "essential": true,
        "memoryReservation": 256,
        "environment": [
            {"name": "PORT", "value": "3000" },
            {"name": "MONGODB_URL", "value": "${db_host}"},
            {"name": "DB_USER", "value": "${db_user}"},
            {"name": "DB_PASS", "value": "${db_password}"},
            {"name": "ALLOWED_HOSTS", "value": "${allowed_hosts}"}
        ],
        "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
                "awslogs-group": "${log_group_name}",
                "awslogs-region": "${log_group_region}",
                "awslogs-stream-prefix": "server"
            }
        },
        "portMappings": [
            {
                "containerPort": 3000,
                "hostPort": 3000
            }
        ]
    }
]
