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
                "id": "select5000000001",
                "maxSelect": 1,
                "name": "type",
                "presentable": false,
                "required": true,
                "system": false,
                "type": "select",
                "values": [
                    "blood_pressure",
                    "blood_sugar",
                    "cholesterol",
                    "hemoglobin",
                    "thyroid",
                    "vitamin_d",
                    "vitamin_b12",
                    "other"
                ]
            },
            {
                "autogeneratePattern": "",
                "hidden": false,
                "id": "text5000000002",
                "max": 0,
                "min": 0,
                "name": "value",
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
                "id": "text5000000003",
                "max": 50,
                "min": 0,
                "name": "unit",
                "pattern": "",
                "presentable": false,
                "primaryKey": false,
                "required": false,
                "system": false,
                "type": "text"
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
                "id": "file5000000004",
                "maxSelect": 1,
                "maxSize": 10485760,
                "mimeTypes": ["image/jpeg", "image/png", "image/webp", "application/pdf"],
                "name": "report_image",
                "presentable": false,
                "protected": true,
                "required": false,
                "system": false,
                "thumbs": null,
                "type": "file"
            },
            {
                "autogeneratePattern": "",
                "hidden": false,
                "id": "text5000000005",
                "max": 0,
                "min": 0,
                "name": "notes",
                "pattern": "",
                "presentable": false,
                "primaryKey": false,
                "required": false,
                "system": false,
                "type": "text"
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
        "id": "pbc_medical_records_001",
        "indexes": [
            "CREATE INDEX idx_medical_records_user_date ON medical_records (user, date DESC)"
        ],
        "listRule": "user = @request.auth.id",
        "name": "medical_records",
        "system": false,
        "type": "base",
        "updateRule": "user = @request.auth.id",
        "viewRule": "user = @request.auth.id"
    });

    return app.save(collection);
}, (app) => {
    const collection = app.findCollectionByNameOrId("pbc_medical_records_001");
    return app.delete(collection);
})
