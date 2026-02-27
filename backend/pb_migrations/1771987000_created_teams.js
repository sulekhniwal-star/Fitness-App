/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
    const collection = new Collection({
        "createRule": "@request.auth.id != ''",
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
                "id": "text2000000001",
                "max": 100,
                "min": 1,
                "name": "name",
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
                "id": "text2000000002",
                "max": 255,
                "min": 0,
                "name": "description",
                "pattern": "",
                "presentable": false,
                "primaryKey": false,
                "required": false,
                "system": false,
                "type": "text"
            },
            {
                "cascadeDelete": false,
                "collectionId": "_pb_users_auth_",
                "hidden": false,
                "id": "relation2000000003",
                "maxSelect": null,
                "minSelect": 0,
                "name": "members",
                "presentable": false,
                "required": false,
                "system": false,
                "type": "relation"
            },
            {
                "hidden": false,
                "id": "number2000000004",
                "max": null,
                "min": 0,
                "name": "total_karma",
                "onlyInt": true,
                "presentable": false,
                "required": false,
                "system": false,
                "type": "number"
            },
            {
                "autogeneratePattern": "",
                "hidden": false,
                "id": "url2000000005",
                "name": "logo_url",
                "onlyDomains": null,
                "exceptDomains": null,
                "presentable": false,
                "required": false,
                "system": false,
                "type": "url"
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
        "id": "pbc_teams_001",
        "indexes": [
            "CREATE INDEX idx_teams_total_karma ON teams (total_karma DESC)"
        ],
        "listRule": null,
        "name": "teams",
        "system": false,
        "type": "base",
        "updateRule": "members.id ?= @request.auth.id",
        "viewRule": null
    });

    return app.save(collection);
}, (app) => {
    const collection = app.findCollectionByNameOrId("pbc_teams_001");
    return app.delete(collection);
})
