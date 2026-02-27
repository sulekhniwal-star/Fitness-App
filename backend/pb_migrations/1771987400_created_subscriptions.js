/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
    const collection = new Collection({
        // Created server-side via payment webhook; users can only read their own records
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
                "id": "text6000000001",
                "max": 0,
                "min": 0,
                "name": "payment_id",
                "pattern": "",
                "presentable": false,
                "primaryKey": false,
                "required": true,
                "system": false,
                "type": "text"
            },
            {
                "hidden": false,
                "id": "select6000000002",
                "maxSelect": 1,
                "name": "plan_name",
                "presentable": false,
                "required": true,
                "system": false,
                "type": "select",
                "values": [
                    "monthly",
                    "quarterly",
                    "yearly",
                    "family"
                ]
            },
            {
                "hidden": false,
                "id": "select6000000003",
                "maxSelect": 1,
                "name": "status",
                "presentable": false,
                "required": true,
                "system": false,
                "type": "select",
                "values": [
                    "active",
                    "cancelled",
                    "expired",
                    "pending"
                ]
            },
            {
                "hidden": false,
                "id": "number6000000004",
                "max": null,
                "min": 0,
                "name": "amount",
                "onlyInt": false,
                "presentable": false,
                "required": false,
                "system": false,
                "type": "number"
            },
            {
                "hidden": false,
                "id": "date6000000005",
                "max": "",
                "min": "",
                "name": "expires_at",
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
        "id": "pbc_subscriptions_001",
        "indexes": [
            "CREATE INDEX idx_subscriptions_user ON subscriptions (user)",
            "CREATE INDEX idx_subscriptions_status ON subscriptions (status)"
        ],
        "listRule": "user = @request.auth.id",
        "name": "subscriptions",
        "system": false,
        "type": "base",
        "updateRule": "",
        "viewRule": "user = @request.auth.id"
    });

    return app.save(collection);
}, (app) => {
    const collection = app.findCollectionByNameOrId("pbc_subscriptions_001");
    return app.delete(collection);
})
