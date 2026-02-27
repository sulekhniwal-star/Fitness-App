/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
    const collection = new Collection({
        "createRule": "user = @request.auth.id",
        "deleteRule": "user = @request.auth.id",
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
                "id": "relation2375276105",
                "maxSelect": 1,
                "minSelect": 0,
                "name": "user",
                "presentable": false,
                "required": true,
                "system": false,
                "type": "relation"
            },
            {
                "autogeneratePattern": "",
                "hidden": false,
                "id": "text3000000001",
                "max": 0,
                "min": 1,
                "name": "content",
                "pattern": "",
                "presentable": false,
                "primaryKey": false,
                "required": true,
                "system": false,
                "type": "text"
            },
            {
                "hidden": false,
                "id": "file3000000002",
                "maxSelect": 1,
                "maxSize": 10485760,
                "mimeTypes": ["image/jpeg", "image/png", "image/webp", "image/gif"],
                "name": "image",
                "presentable": false,
                "protected": false,
                "required": false,
                "system": false,
                "thumbs": ["600x400"],
                "type": "file"
            },
            {
                "cascadeDelete": false,
                "collectionId": "_pb_users_auth_",
                "hidden": false,
                "id": "relation3000000003",
                "maxSelect": null,
                "minSelect": 0,
                "name": "likes",
                "presentable": false,
                "required": false,
                "system": false,
                "type": "relation"
            },
            {
                "cascadeDelete": false,
                "collectionId": "pbc_challenges_001",
                "hidden": false,
                "id": "relation3000000004",
                "maxSelect": 1,
                "minSelect": 0,
                "name": "challenge",
                "presentable": false,
                "required": false,
                "system": false,
                "type": "relation"
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
        "id": "pbc_posts_001",
        "indexes": [
            "CREATE INDEX idx_posts_created ON posts (created DESC)"
        ],
        "listRule": null,
        "name": "posts",
        "system": false,
        "type": "base",
        "updateRule": "user = @request.auth.id",
        "viewRule": null
    });

    return app.save(collection);
}, (app) => {
    const collection = app.findCollectionByNameOrId("pbc_posts_001");
    return app.delete(collection);
})
