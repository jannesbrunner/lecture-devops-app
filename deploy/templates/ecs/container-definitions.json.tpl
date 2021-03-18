[
    {
        "name": "server",
        "image": "${app_image}",
        "essential": true,
        "memoryReservation": 256,
        "environment": [
            {"name": "PORT", "value": "3000" },
            {"name": "DB_URL", "value": "127.0.0.1:27017/todo-app"}
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
    },

    {
        "name": "db",
        "image": "${db_image}",
        "essential": true,
        "memoryReservation": 256,
        "environment": [],
        "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
                "awslogs-group": "${log_group_name}",
                "awslogs-region": "${log_group_region}",
                "awslogs-stream-prefix": "mongodb"
            }
        },
        "portMappings": [
            {
                "containerPort": 27017,
                "hostPort": 27017
            }
        ]
    }
]
