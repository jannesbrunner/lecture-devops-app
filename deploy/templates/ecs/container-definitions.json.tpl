[
    {
        "name": "server",
        "image": "${app_image}",
        "essential": true,
        "memoryReservation": 512,
        "environment": [
            {"name": "PORT", "value": "3000" },
            {"name": "DB_URL", "value": "${db_url}"},
            {"name": "DB_USERNAME", "value": "${db_username}"},
            {"name": "DB_PASSWORD", "value": "${db_password}"},
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
