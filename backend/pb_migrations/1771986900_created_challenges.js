/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
    const collection = new Collection({
        // Challenges are admin-created but users can read and join them
        "createRule": "",
        "deleteRule": "",
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
                "autogeneratePattern": "",
                "hidden": false,
                "id": "text1234500000",
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
                "id": "text1234500001",
                "max": 0,
                "min": 0,
                "name": "description",
                "pattern": "",
                "presentable": false,
                "primaryKey": false,
                "required": true,
                "system": false,
                "type": "text"
            },
            {
                "hidden": false,
                "id": "select1234500002",
                "maxSelect": 1,
                "name": "goal_type",
                "presentable": false,
                "required": true,
                "system": false,
                "type": "select",
                "values": [
                    "steps",
                    "workout",
                    "calories",
                    "water",
                    "weight"
                ]
            },
            {
                "hidden": false,
                "id": "number1234500003",
                "max": null,
                "min": 0,
                "name": "goal_value",
                "onlyInt": false,
                "presentable": false,
                "required": true,
                "system": false,
                "type": "number"
            },
            {
                "hidden": false,
                "id": "number1234500004",
                "max": null,
                "min": 0,
                "name": "reward_points",
                "onlyInt": true,
                "presentable": false,
                "required": true,
                "system": false,
                "type": "number"
            },
            {
                "hidden": false,
                "id": "date1234500005",
                "max": "",
                "min": "",
                "name": "start_date",
                "presentable": false,
                "required": true,
                "system": false,
                "type": "date"
            },
            {
                "hidden": false,
                "id": "date1234500006",
                "max": "",
                "min": "",
                "name": "end_date",
                "presentable": false,
                "required": true,
                "system": false,
                "type": "date"
            },
            {
                "cascadeDelete": false,
                "collectionId": "_pb_users_auth_",
                "hidden": false,
                "id": "relation1234500007",
                "maxSelect": null,
                "minSelect": 0,
                "name": "participants",
                "presentable": false,
                "required": false,
                "system": false,
                "type": "relation"
            },
            {
                "hidden": false,
                "id": "bool1234500008",
                "name": "is_team_challenge",
                "presentable": false,
                "required": false,
                "system": false,
                "type": "bool"
            },
            {
                "hidden": false,
                "id": "file1234500009",
                "maxSelect": 1,
                "maxSize": 5242880,
                "mimeTypes": ["image/jpeg", "image/png", "image/webp"],
                "name": "image",
                "presentable": false,
                "protected": false,
                "required": false,
                "system": false,
                "thumbs": ["300x200"],
                "type": "file"
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
        "id": "pbc_challenges_001",
        "indexes": [],
        "listRule": null,
        "name": "challenges",
        "system": false,
        "type": "base",
        "updateRule": "",
        "viewRule": null
    });

    return app.save(collection);
}, (app) => {
    const collection = app.findCollectionByNameOrId("pbc_challenges_001");
    return app.delete(collection);
})
