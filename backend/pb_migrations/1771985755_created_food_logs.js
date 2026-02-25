/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = new Collection({
    "createRule": "user = @request.auth.id\n",
    "deleteRule": "user = @request.auth.id\n",
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
        "id": "select2516616413",
        "maxSelect": 1,
        "name": "meal_type",
        "presentable": false,
        "required": true,
        "system": false,
        "type": "select",
        "values": [
          "breakfast",
          "lunch",
          "dinner",
          "snack",
          "chai"
        ]
      },
      {
        "cascadeDelete": false,
        "collectionId": "pbc_4006550583",
        "hidden": false,
        "id": "relation2856095183",
        "maxSelect": 1,
        "minSelect": 0,
        "name": "food_item",
        "presentable": false,
        "required": true,
        "system": false,
        "type": "relation"
      },
      {
        "hidden": false,
        "id": "number3538164808",
        "max": null,
        "min": null,
        "name": "quantity_g",
        "onlyInt": false,
        "presentable": false,
        "required": true,
        "system": false,
        "type": "number"
      },
      {
        "hidden": false,
        "id": "number627390209",
        "max": null,
        "min": null,
        "name": "calories",
        "onlyInt": false,
        "presentable": false,
        "required": true,
        "system": false,
        "type": "number"
      },
      {
        "hidden": false,
        "id": "select1185406054",
        "maxSelect": 1,
        "name": "logged_via",
        "presentable": false,
        "required": true,
        "system": false,
        "type": "select",
        "values": [
          "search",
          "barcode",
          "ocr",
          "voice",
          "manual"
        ]
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
    "id": "pbc_562268181",
    "indexes": [],
    "listRule": "user = @request.auth.id\n",
    "name": "food_logs",
    "system": false,
    "type": "base",
    "updateRule": "user = @request.auth.id\n",
    "viewRule": "user = @request.auth.id\n"
  });

  return app.save(collection);
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_562268181");

  return app.delete(collection);
})
