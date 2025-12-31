<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Simple Music</title>
    
    <script src="https://www.gstatic.com/firebasejs/9.22.1/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.22.1/firebase-firestore-compat.js"></script>

    <style>
        body {
            font-family: sans-serif;
            background-color: #f4f4f9;
            margin: 0;
            padding: 20px;
            display: flex;
            flex-direction: column;
            align-items: center;
        }
        .container {
            width: 100%;
            max-width: 500px;
            background: white;
            padding: 20px;
            border-radius: 15px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }
        h1 { text-align: center; color: #333; }
        
        /* Список треков */
        .track-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 15px;
            border-bottom: 1px solid #eee;
            cursor: pointer;
            transition: 0.2s;
        }
        .track-item:hover { background: #f0f0f0; }
        .track-info b { display: block; font-size: 16px; }
        .track-info span { color: #888; font-size: 14px; }

        /* Плеер внизу */
        .player-panel {
            position: fixed;
            bottom: 0;
            left: 0;
            width: 100%;
            background: #333;
            color: white;
            padding: 15px;
            box-sizing: border-box;
            display: none; /* Скрыт, пока не выберем песню */
            text-align: center;
        }
        audio { width: 100%; max-width: 500px; margin-top: 10px; }

        /* Кнопка добавления */
        .add-btn {
            background: #28a745;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 5px;
            cursor: pointer;
            margin-bottom: 20px;
            width: 100%;
        }
    </style>
</head>
<body>

    <div class="container">
        <h1>Моя Музыка</h1>
        
        <button class="add-btn" onclick="addTrack()">+ Добавить новый трек</button>

        <div id="track-list">
            <p style="text-align:center;">Загрузка песен...</p>
        </div>
    </div>

    <div id="player-panel" class="player-panel">
        <div id="now-playing"><b>Песня</b> - Артист</div>
        <audio id="main-audio" controls autoplay></audio>
    </div>

    <script>
        // 1. Твои настройки Firebase (обязательно проверь их)
        const firebaseConfig = {
            apiKey: "AIzaSyBXsLSl_6HNpLm3TqPTjkTRqo62gb2j968",
            authDomain: "m-flow-65777.firebaseapp.com",
            projectId: "m-flow-65777",
            storageBucket: "m-flow-65777.firebasestorage.app",
            messagingSenderId: "598827175490",
            appId: "1:598827175490:web:26618e76510f296f7267db"
        };

        firebase.initializeApp(firebaseConfig);
        const db = firebase.firestore();

        // 2. Функция для исправления ссылок Google Drive
        function formatDriveLink(url) {
            if (url.includes('drive.google.com')) {
                let fileId = "";
                if (url.includes('/d/')) {
                    fileId = url.split('/d/')[1].split('/')[0];
                } else if (url.includes('id=')) {
                    fileId = url.split('id=')[1].split('&')[0];
                }
                return `https://docs.google.com/uc?export=download&id=${fileId}`;
            }
            return url;
        }

        // 3. Загрузка списка треков
        async function loadTracks() {
            const trackListDiv = document.getElementById('track-list');
            
            db.collection('tracks').orderBy('createdAt', 'desc').onSnapshot(snapshot => {
                trackListDiv.innerHTML = "";
                if (snapshot.empty) {
                    trackListDiv.innerHTML = "<p style='text-align:center;'>Песен пока нет</p>";
                }
                snapshot.forEach(doc => {
                    const track = doc.data();
                    const item = document.createElement('div');
                    item.className = 'track-item';
                    item.innerHTML = `
                        <div class="track-info">
                            <b>${track.title}</b>
                            <span>${track.artist}</span>
                        </div>
                        <div style="color: #28a745;">▶</div>
                    `;
                    item.onclick = () => playSong(track.title, track.artist, track.audio);
                    trackListDiv.appendChild(item);
                });
            });
        }

        // 4. Запуск проигрывателя
        function playSong(title, artist, url) {
            const panel = document.getElementById('player-panel');
            const audio = document.getElementById('main-audio');
            const info = document.getElementById('now-playing');

            info.innerHTML = `<b>${title}</b> - ${artist}`;
            audio.src = formatDriveLink(url);
            panel.style.display = 'block';
            audio.play().catch(e => alert("Ошибка: Проверьте доступ к файлу на Диске!"));
        }

        // 5. Функция добавления (всплывающие окна)
        async function addTrack() {
            const title = prompt("Название песни:");
            const artist = prompt("Автор:");
            const audio = prompt("Ссылка на Google Drive:");

            if (title && artist && audio) {
                await db.collection('tracks').add({
                    title: title,
                    artist: artist,
                    audio: audio,
                    createdAt: Date.now()
                });
                alert("Добавлено!");
            }
        }

        // Запускаем загрузку при открытии
        loadTracks();
    </script>
</body>
</html>
