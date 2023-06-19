# Python Base Image
python:3.9.17-buster
3.9
buster = Debian 12.4

**Databricks Runtime 12.2-LTS**
* **minimal**: https://github.com/databricks/containers/blob/release-12.2-LTS/ubuntu/minimal/Dockerfile
* **python**: https://github.com/databricks/containers/blob/release-12.2-LTS/ubuntu/python/
    - FROM databricksruntime/minimal:12.2-LTS
* **dbfsfuse**: https://github.com/databricks/containers/blob/release-12.2-LTS/ubuntu/dbfsfuse/Dockerfile
    - FROM databricksruntime/python:12.2-LTS
* **standard**: https://github.com/databricks/containers/blob/release-12.2-LTS/ubuntu/standard/Dockerfile
    - FROM databricksruntime/dbfsfuse:12.2-LTS


Chat GPT Chat: https://chat.openai.com/share/9e4c646d-ee2f-4cc7-bd96-aab9723597eb