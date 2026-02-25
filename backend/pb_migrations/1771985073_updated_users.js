/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("_pb_users_auth_")

  // update collection data
  unmarshal({
    "oauth2": {
      "mappedFields": {
        "avatarURL": "",
        "name": ""
      }
    }
  }, collection)

  // add field
  collection.fields.addAt(8, new Field({
    "autogeneratePattern": "",
    "hidden": false,
    "id": "text2240723161",
    "max": 0,
    "min": 0,
    "name": "Phone",
    "pattern": "",
    "presentable": false,
    "primaryKey": false,
    "required": false,
    "system": false,
    "type": "text"
  }))

  // add field
  collection.fields.addAt(9, new Field({
    "hidden": false,
    "id": "date1742835576",
    "max": "",
    "min": "",
    "name": "DOB",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "date"
  }))

  // add field
  collection.fields.addAt(10, new Field({
    "hidden": false,
    "id": "select3236630388",
    "maxSelect": 1,
    "name": "Gender",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "select",
    "values": [
      "Male",
      "Female",
      "Other"
    ]
  }))

  // add field
  collection.fields.addAt(11, new Field({
    "hidden": false,
    "id": "number4074889273",
    "max": null,
    "min": null,
    "name": "Height",
    "onlyInt": false,
    "presentable": false,
    "required": false,
    "system": false,
    "type": "number"
  }))

  // add field
  collection.fields.addAt(12, new Field({
    "hidden": false,
    "id": "number483296327",
    "max": null,
    "min": null,
    "name": "Weight_kg",
    "onlyInt": false,
    "presentable": false,
    "required": false,
    "system": false,
    "type": "number"
  }))

  // add field
  collection.fields.addAt(13, new Field({
    "hidden": false,
    "id": "select3375532201",
    "maxSelect": 1,
    "name": "Dosha",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "select",
    "values": [
      "Vata",
      "Pitta",
      "Kapha",
      "Unknown"
    ]
  }))

  // add field
  collection.fields.addAt(14, new Field({
    "hidden": false,
    "id": "select3543667429",
    "maxSelect": 1,
    "name": "Preffered_Language",
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
      "bn"
    ]
  }))

  // add field
  collection.fields.addAt(15, new Field({
    "hidden": false,
    "id": "select329418644",
    "maxSelect": 1,
    "name": "subscription_tier",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "select",
    "values": [
      "Free",
      "Monthly",
      "Quarterly",
      "Yearly",
      "Family"
    ]
  }))

  // update field
  collection.fields.addAt(6, new Field({
    "autogeneratePattern": "",
    "hidden": false,
    "id": "text1579384326",
    "max": 255,
    "min": 0,
    "name": "Name",
    "pattern": "",
    "presentable": false,
    "primaryKey": false,
    "required": false,
    "system": false,
    "type": "text"
  }))

  // update field
  collection.fields.addAt(7, new Field({
    "hidden": false,
    "id": "file376926767",
    "maxSelect": 1,
    "maxSize": 0,
    "mimeTypes": [
      "image/jpeg",
      "image/png",
      "image/svg+xml",
      "image/gif",
      "image/webp"
    ],
    "name": "Avatar",
    "presentable": false,
    "protected": false,
    "required": false,
    "system": false,
    "thumbs": null,
    "type": "file"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("_pb_users_auth_")

  // update collection data
  unmarshal({
    "oauth2": {
      "mappedFields": {
        "avatarURL": "avatar",
        "name": "name"
      }
    }
  }, collection)

  // remove field
  collection.fields.removeById("text2240723161")

  // remove field
  collection.fields.removeById("date1742835576")

  // remove field
  collection.fields.removeById("select3236630388")

  // remove field
  collection.fields.removeById("number4074889273")

  // remove field
  collection.fields.removeById("number483296327")

  // remove field
  collection.fields.removeById("select3375532201")

  // remove field
  collection.fields.removeById("select3543667429")

  // remove field
  collection.fields.removeById("select329418644")

  // update field
  collection.fields.addAt(6, new Field({
    "autogeneratePattern": "",
    "hidden": false,
    "id": "text1579384326",
    "max": 255,
    "min": 0,
    "name": "name",
    "pattern": "",
    "presentable": false,
    "primaryKey": false,
    "required": false,
    "system": false,
    "type": "text"
  }))

  // update field
  collection.fields.addAt(7, new Field({
    "hidden": false,
    "id": "file376926767",
    "maxSelect": 1,
    "maxSize": 0,
    "mimeTypes": [
      "image/jpeg",
      "image/png",
      "image/svg+xml",
      "image/gif",
      "image/webp"
    ],
    "name": "avatar",
    "presentable": false,
    "protected": false,
    "required": false,
    "system": false,
    "thumbs": null,
    "type": "file"
  }))

  return app.save(collection)
})
