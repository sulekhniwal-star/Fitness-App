/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
    const collection = app.findCollectionByNameOrId("_pb_users_auth_")

    // add field: karma_points
    collection.fields.addAt(16, new Field({
        "hidden": false,
        "id": "number1234567890",
        "max": null,
        "min": 0,
        "name": "karma_points",
        "onlyInt": true,
        "presentable": false,
        "required": false,
        "system": false,
        "type": "number"
    }))

    return app.save(collection)
}, (app) => {
    const collection = app.findCollectionByNameOrId("_pb_users_auth_")

    // remove field
    collection.fields.removeById("number1234567890")

    return app.save(collection)
})
