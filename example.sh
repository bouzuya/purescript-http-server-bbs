#!/bin/bash -e

echo 'POST /threads (thread1)'
curl -X POST -d '{"content":"thread1 content","title":"thread1"}' -s 'http://localhost:8080/threads' | jq -S .
echo

echo 'POST /threads (thread2)'
thread2_id=$(curl -X POST -d '{"content":"thread2 content","title":"thread2"}' -s 'http://localhost:8080/threads' | jq -r '.id')
echo "${thread2_id}"
echo

echo 'GET /threads/{thread_id} (thread2)'
curl -s "http://localhost:8080/threads/${thread2_id}" | jq -S .
echo

echo 'GET /threads'
curl -s 'http://localhost:8080/threads' | jq -S .
echo



echo 'POST /messages (message1 -> thread2)'
curl -X POST -d '{"content":"message1","thread_id":"'"${thread2_id}"'"}' -s 'http://localhost:8080/messages' | jq -S .
echo

echo 'POST /threads/{thread_id}/messages (message2 -> thread2)'
message2_id=$(curl -X POST -d '{"content":"message2"}' -s "http://localhost:8080/threads/${thread2_id}/messages" | jq -r '.id')
echo "${message2_id}"
echo

echo 'GET /messages/{message_id} (message2)'
curl -s "http://localhost:8080/messages/${message2_id}" | jq -S .
echo

echo 'GET /threads/{thread_id}/messages (thread2)'
curl -s "http://localhost:8080/threads/${thread2_id}/messages" | jq -S .
echo
