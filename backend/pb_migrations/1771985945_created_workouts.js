/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = new Collection({
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
        "id": "text724990059",
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
        "hidden": false,
        "id": "select105650625",
        "maxSelect": 1,
        "name": "category",
        "presentable": false,
        "required": true,
        "system": false,
        "type": "select",
        "values": [
          "yoga",
          "dance",
          "desi",
          "hiit",
          "sports"
        ]
      },
      {
        "hidden": false,
        "id": "number1116771874",
        "max": null,
        "min": null,
        "name": "duration_min",
        "onlyInt": false,
        "presentable": false,
        "required": true,
        "system": false,
        "type": "number"
      },
      {
        "autogeneratePattern": "",
        "hidden": false,
        "id": "text3145613521",
        "max": 0,
        "min": 0,
        "name": "youtube_id",
        "pattern": "",
        "presentable": false,
        "primaryKey": false,
        "required": true,
        "system": false,
        "type": "text"
      },
      {
        "exceptDomains": null,
        "hidden": false,
        "id": "url2170429563",
        "name": "thumbnail_url",
        "onlyDomains": null,
        "presentable": false,
        "required": false,
        "system": false,
        "type": "url"
      },
      {
        "hidden": false,
        "id": "select3144380399",
        "maxSelect": 1,
        "name": "difficulty",
        "presentable": false,
        "required": true,
        "system": false,
        "type": "select",
        "values": [
          "beginner",
          "intermediate",
          "advanced"
        ]
      },
      {
        "hidden": false,
        "id": "select2698072953",
        "maxSelect": 1,
        "name": "languages",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "select",
        "values": [
          "en",
          "hi",
          "ta",
          "te",
          "mr",
          "bn",
          "multi"
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
    "id": "pbc_3845069049",
    "indexes": [],
    "listRule": null,
    "name": "workouts",
    "system": false,
    "type": "base",
    "updateRule": "",
    "viewRule": null
  });

  return app.save(collection);
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_3845069049");

  return app.delete(collection);
})
