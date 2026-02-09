[ TO LLM: Start

LLM rewrite the first part by guilding the user how to build the dockerfile.. so that `lean-aider` is usable.

Then the following is how one should run the lean-aider docker image. It will use lean and lake and mathlib from the host machine. One way to test is that after getting into aider, the user can `/run lean --version` to test whether it's successful. -- Can they even run ./bin/test.sh in the docker? We should try this out. If that passes that proves it has full LEAN functionality in the docker image (highly preferrable)!

] TO LLM: End


docker_args=(
    run -it                                   # 啟動互動模式並配置終端機 (TTY)
    --rm                                      # 容器結束後自動刪除，保持環境整潔
    --user "$(id -u):$(id -g)"                # 以當前使用者的身份執行，避免產生 root 權限檔案
    --volume "$(pwd):/app"                    # 將當前資料夾掛載至容器內，讓 AI 能存取程式碼
    --volume ~/.elan:/opt/elan 
    --volume ~/.cache:/opt/cache 
    --env ELAN_HOME=/opt/elan 
    --env PATH="/opt/elan/bin:/usr/local/bin:/usr/bin:/bin" 
    --env GIT_AUTHOR_NAME="$(git config user.name)" 
    --env GIT_AUTHOR_EMAIL="$(git config user.email)" 
    --env GIT_COMMITTER_NAME="$(git config user.name)" 
    --env GIT_COMMITTER_EMAIL="$(git config user.email)"
    --env GEMINI_API_KEY="AIza_YOURSECRET_API_KEY"
    
    lean-aider
    --model gemini/gemini-2.5-pro             # 指定主模型：負責複雜的邏輯推理與撰寫程式
    --no-stream                               # 關閉串流輸出：等待完整回應後再一次顯示
    --weak-model gemini/gemini-2.0-flash-lite # 指定副模型：處理簡單任務以節省成本或配額
)
docker "${docker_args[@]}"
