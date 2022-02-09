const mysql = require('serverless-mysql')({
    config: {
        host     : process.env.database_endpoint,
        database : "ghost",
        user     : process.env.database_username,
        password : process.env.database_password
    }
});

exports.handler = async function(event, context) {
    await mysql.query('DELETE FROM posts_authors')
    await mysql.query('DELETE FROM posts_meta')
    await mysql.query('DELETE FROM posts_products')
    await mysql.query('DELETE FROM posts_tags')
    await mysql.query('DELETE FROM posts')
}
