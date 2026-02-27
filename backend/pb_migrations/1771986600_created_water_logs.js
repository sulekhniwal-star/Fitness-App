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
                "hidden": false,
                "id": "date2862495610",
                "max": "",
                "min": "",
                "name": "date",
                "presentable": false,
                "required": true,
                "system": false,
                "type": "date"
            },
            {
                "hidden": false,
                "id": "number1111111111",
                "max": null,
                "min": 0,
                "name": "amount_ml",
                "onlyInt": true,
                "presentable": false,
                "required": true,
                "system": false,
                "type": "number"
            },
            {
                "hidden": false,
                "id": "number2222222222",
                "max": null,
                "min": 0,
                "name": "goal_ml",
                "onlyInt": true,
                "presentable": false,
                "required": false,
                "system": false,
                "type": "number"
            },
            {
                "hidden": false,
                "id": "date3333333333",
                "max": "",
                "min": "",
                "name": "time",
                "presentable": false,
                "required": false,
                "system": false,
                "type": "date"
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
        "id": "pbc_water_logs_001",
        "indexes": [
            "CREATE INDEX idx_water_logs_user_date ON water_logs (user, date)"
        ],
        "listRule": "user = @request.auth.id",
        "name": "water_logs",
        "system": false,
        "type": "base",
        "updateRule": "user = @request.auth.id",
        "viewRule": "user = @request.auth.id"
    });

    return app.save(collection);
}, (app) => {
    const collection = app.findCollectionByNameOrId("pbc_water_logs_001");
    return app.delete(collection);
})
