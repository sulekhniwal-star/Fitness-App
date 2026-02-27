/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
    const collection = new Collection({
        // Notifications are created server-side (by hooks or admin), users can only read their own
        "createRule": "",
        "deleteRule": "@request.auth.id != ''",
        "fields": [
            {
                "autogeneratePattern": "[a-z0-9]{15}",
                "hidden": false,
                "id": "text3208210256",
                "max": 15,
                "min": 15,
                "name": "id",
                "pattern": "^[a-z0-9]+$",
                "presentable": false,
                "primaryKey": true,
                "required": true,
                "system": true,
                "type": "text"
            },
            {
                "cascadeDelete": true,
                "collectionId": "_pb_users_auth_",
                "hidden": false,
                "id": "relation4000000001",
                "maxSelect": 1,
                "minSelect": 0,
                "name": "user_id",
                "presentable": false,
                "required": true,
                "system": false,
                "type": "relation"
            },
            {
                "autogeneratePattern": "",
                "hidden": false,
                "id": "text4000000002",
                "max": 0,
                "min": 0,
                "name": "title",
                "pattern": "",
                "presentable": false,
                "primaryKey": false,
                "required": true,
                "system": false,
                "type": "text"
            },
            {
                "autogeneratePattern": "",
                "hidden": false,
                "id": "text4000000003",
                "max": 0,
                "min": 0,
                "name": "message",
                "pattern": "",
                "presentable": false,
                "primaryKey": false,
                "required": true,
                "system": false,
                "type": "text"
            },
            {
                "hidden": false,
                "id": "select4000000004",
                "maxSelect": 1,
                "name": "type",
                "presentable": false,
                "required": true,
                "system": false,
                "type": "select",
                "values": [
                    "info",
                    "warning",
                    "challenge",
                    "karma",
                    "social",
                    "system"
                ]
            },
            {
                "hidden": false,
                "id": "bool4000000005",
                "name": "is_read",
                "presentable": false,
                "required": false,
                "system": false,
                "type": "bool"
            },
            {
                "hidden": false,
                "id": "autodate2990389176",
                "name": "created",
                "onCreate": true,
                "onUpdate": false,
                "presentable": false,
                "system": false,
                "type": "autodate"
            },
            {
                "hidden": false,
                "id": "autodate3332085495",
                "name": "updated",
                "onCreate": true,
                "onUpdate": true,
                "presentable": false,
                "system": false,
                "type": "autodate"
            }
        ],
        "id": "pbc_notifications_001",
        "indexes": [
            "CREATE INDEX idx_notifications_user_created ON notifications (user_id, created DESC)"
        ],
        "listRule": "user_id = @request.auth.id",
        "name": "notifications",
        "system": false,
        "type": "base",
        "updateRule": "user_id = @request.auth.id",
        "viewRule": "user_id = @request.auth.id"
    });

    return app.save(collection);
}, (app) => {
    const collection = app.findCollectionByNameOrId("pbc_notifications_001");
    return app.delete(collection);
})
