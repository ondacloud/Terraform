from flask import Flask, jsonify, abort

app = Flask(__name__)

@app.route('/version', methods=['GET'])
def get_version():
    try:
        ret = {"version": "v1.0.0"}
        return jsonify(ret), 200
    except Exception as e:
        app.logger.error(e)
        abort(500)

@app.route('/healthcheck', methods=['GET'])
def get_healthcheck():
    try:
        ret = {"status": "ok"}
        return jsonify(ret), 200
    except Exception as e:
        app.logger.error(e)
        abort(500)

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=8080, debug=True)