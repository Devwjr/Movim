import 'package:equatable/equatable.dart';

enum TemplateCategory {
  frontend,
  backend,
  fullstack,
  mobile,
  database,
  utility,
}

class TemplateFile extends Equatable {
  final String path;
  final String content;
  final String? description;

  const TemplateFile({
    required this.path,
    required this.content,
    this.description,
  });

  @override
  List<Object?> get props => [path, content, description];
}

class TemplateEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final TemplateCategory category;
  final List<String> tags;
  final List<TemplateFile> files;
  final Map<String, String> dependencies;
  final List<String> commands;
  final String? icon;
  final String? author;
  final String? version;
  final bool isFeatured;

  const TemplateEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.tags = const [],
    this.files = const [],
    this.dependencies = const {},
    this.commands = const [],
    this.icon,
    this.author,
    this.version = '1.0.0',
    this.isFeatured = false,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        category,
        tags,
        files,
        dependencies,
        commands,
        icon,
        author,
        version,
        isFeatured,
      ];

  TemplateEntity copyWith({
    String? id,
    String? name,
    String? description,
    TemplateCategory? category,
    List<String>? tags,
    List<TemplateFile>? files,
    Map<String, String>? dependencies,
    List<String>? commands,
    String? icon,
    String? author,
    String? version,
    bool? isFeatured,
  }) {
    return TemplateEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      files: files ?? this.files,
      dependencies: dependencies ?? this.dependencies,
      commands: commands ?? this.commands,
      icon: icon ?? this.icon,
      author: author ?? this.author,
      version: version ?? this.version,
      isFeatured: isFeatured ?? this.isFeatured,
    );
  }
}

class DefaultTemplates {
  static final List<TemplateEntity> templates = [
    TemplateEntity(
      id: 'react-basic',
      name: 'React Basic',
      description: 'Template básico para aplicações React com Vite',
      category: TemplateCategory.frontend,
      tags: ['react', 'vite', 'javascript', 'frontend'],
      icon: '⚛️',
      author: 'MobileVim',
      isFeatured: true,
      dependencies: {
        'react': '^18.2.0',
        'react-dom': '^18.2.0',
      },
      commands: [
        'npm create vite@latest . -- --template react',
        'npm install',
        'npm run dev',
      ],
      files: [
        const TemplateFile(
          path: 'package.json',
          content: '''{
  "name": "mobilevim-react-app",
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0"
  },
  "devDependencies": {
    "@types/react": "^18.2.0",
    "@types/react-dom": "^18.2.0",
    "@vitejs/plugin-react": "^4.0.0",
    "vite": "^5.0.0"
  }
}''',
          description: 'Configuração do npm',
        ),
        const TemplateFile(
          path: 'src/main.jsx',
          content: '''import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';
import './index.css';

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);''',
          description: 'Ponto de entrada da aplicação',
        ),
        const TemplateFile(
          path: 'src/App.jsx',
          content: '''import { useState } from 'react';
import './App.css';

function App() {
  const [count, setCount] = useState(0);

  return (
    <div className="App">
      <h1>MobileVim + React</h1>
      <div className="card">
        <button onClick={() => setCount((count) => count + 1)}>
          Contador: {count}
        </button>
      </div>
      <p className="read-the-docs">
        Editando com MobileVim no estilo Neovim
      </p>
    </div>
  );
}

export default App;''',
          description: 'Componente principal',
        ),
      ],
    ),
    TemplateEntity(
      id: 'vue-basic',
      name: 'Vue.js Basic',
      description: 'Template básico para Vue.js 3 com Vite',
      category: TemplateCategory.frontend,
      tags: ['vue', 'vite', 'javascript', 'frontend'],
      icon: '💚',
      author: 'MobileVim',
      isFeatured: true,
      commands: [
        'npm create vite@latest . -- --template vue',
        'npm install',
        'npm run dev',
      ],
      files: [],
    ),
    TemplateEntity(
      id: 'nextjs-basic',
      name: 'Next.js Basic',
      description: 'Template Next.js 14 com App Router',
      category: TemplateCategory.frontend,
      tags: ['nextjs', 'react', 'ssr', 'frontend'],
      icon: '▲',
      author: 'MobileVim',
      isFeatured: true,
      commands: [
        'npx create-next-app@latest .',
      ],
      files: [],
    ),
    TemplateEntity(
      id: 'express-basic',
      name: 'Express.js Basic',
      description: 'API REST básica com Node.js e Express',
      category: TemplateCategory.backend,
      tags: ['nodejs', 'express', 'api', 'backend'],
      icon: '🟢',
      author: 'MobileVim',
      isFeatured: true,
      dependencies: {
        'express': '^4.18.0',
        'cors': '^2.8.5',
        'dotenv': '^16.3.0',
      },
      commands: [
        'npm init -y',
        'npm install express cors dotenv',
        'npm install -D nodemon',
      ],
      files: [
        const TemplateFile(
          path: 'server.js',
          content: '''const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', message: 'MobileVim Express API' });
});

app.get('/api/users', (req, res) => {
  res.json([
    { id: 1, name: 'João Silva' },
    { id: 2, name: 'Maria Santos' },
  ]);
});

app.listen(PORT, () => {
  console.log(\`Servidor rodando na porta \${PORT}\`);
});''',
          description: 'Servidor Express principal',
        ),
        const TemplateFile(
          path: 'package.json',
          content: '''{
  "name": "mobilevim-express-api",
  "version": "1.0.0",
  "description": "API Express criada com MobileVim",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "dotenv": "^16.3.1"
  },
  "devDependencies": {
    "nodemon": "^3.0.1"
  }
}''',
          description: 'Configuração do npm',
        ),
      ],
    ),
    TemplateEntity(
      id: 'fastapi-basic',
      name: 'FastAPI Basic',
      description: 'API REST moderna com Python FastAPI',
      category: TemplateCategory.backend,
      tags: ['python', 'fastapi', 'api', 'backend'],
      icon: '🐍',
      author: 'MobileVim',
      isFeatured: true,
      commands: [
        'pip install fastapi uvicorn',
        'uvicorn main:app --reload',
      ],
      files: [
        const TemplateFile(
          path: 'main.py',
          content: '''from fastapi import FastAPI
from pydantic import BaseModel
from typing import List, Optional

app = FastAPI(title="MobileVim FastAPI", version="1.0.0")


class User(BaseModel):
    id: Optional[int] = None
    name: str
    email: str


users_db: List[User] = [
    User(id=1, name="João Silva", email="joao@email.com"),
    User(id=2, name="Maria Santos", email="maria@email.com"),
]


@app.get("/")
def root():
    return {"message": "Bem-vindo ao MobileVim FastAPI!", "docs": "/docs"}


@app.get("/api/health")
def health_check():
    return {"status": "ok"}


@app.get("/api/users", response_model=List[User])
def get_users():
    return users_db


@app.get("/api/users/{user_id}", response_model=User)
def get_user(user_id: int):
    for user in users_db:
        if user.id == user_id:
            return user
    return {"error": "Usuário não encontrado"}


@app.post("/api/users", response_model=User)
def create_user(user: User):
    new_id = max((u.id for u in users_db), default=0) + 1
    user.id = new_id
    users_db.append(user)
    return user


if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
''',
          description: 'Arquivo principal do FastAPI',
        ),
        const TemplateFile(
          path: 'requirements.txt',
          content: '''fastapi==0.104.1
uvicorn[standard]==0.24.0
pydantic==2.5.0
python-multipart==0.0.6
''',
          description: 'Dependências Python',
        ),
      ],
    ),
    TemplateEntity(
      id: 'flutter-basic',
      name: 'Flutter Basic',
      description: 'Aplicativo Flutter básico com estrutura limpa',
      category: TemplateCategory.mobile,
      tags: ['flutter', 'dart', 'mobile', 'cross-platform'],
      icon: '💙',
      author: 'MobileVim',
      isFeatured: true,
      commands: [
        'flutter create .',
        'flutter pub get',
        'flutter run',
      ],
      files: [],
    ),
    TemplateEntity(
      id: 'nestjs-basic',
      name: 'NestJS Basic',
      description: 'API Node.js escalável com NestJS',
      category: TemplateCategory.backend,
      tags: ['nestjs', 'nodejs', 'typescript', 'api'],
      icon: '🏠',
      author: 'MobileVim',
      commands: [
        'npm i -g @nestjs/cli',
        'nest new .',
      ],
      files: [],
    ),
    TemplateEntity(
      id: 'laravel-basic',
      name: 'Laravel Basic',
      description: 'Aplicação PHP com Laravel framework',
      category: TemplateCategory.backend,
      tags: ['laravel', 'php', 'web', 'mvc'],
      icon: '🔴',
      author: 'MobileVim',
      commands: [
        'composer create-project laravel/laravel .',
        'php artisan serve',
      ],
      files: [],
    ),
    TemplateEntity(
      id: 'django-basic',
      name: 'Django Basic',
      description: 'Web framework Python Django',
      category: TemplateCategory.backend,
      tags: ['django', 'python', 'web', 'mvc'],
      icon: '🎸',
      author: 'MobileVim',
      commands: [
        'pip install django',
        'django-admin startproject project .',
        'python manage.py runserver',
      ],
      files: [],
    ),
    TemplateEntity(
      id: 'react-native-basic',
      name: 'React Native Basic',
      description: 'Aplicativo móvel com React Native',
      category: TemplateCategory.mobile,
      tags: ['react-native', 'mobile', 'javascript', 'ios', 'android'],
      icon: '⚛️',
      author: 'MobileVim',
      commands: [
        'npx react-native@latest init MobileVimApp',
      ],
      files: [],
    ),
    TemplateEntity(
      id: 'svelte-basic',
      name: 'Svelte Basic',
      description: 'Aplicação Svelte com Vite',
      category: TemplateCategory.frontend,
      tags: ['svelte', 'vite', 'javascript', 'frontend'],
      icon: '🟠',
      author: 'MobileVim',
      commands: [
        'npm create vite@latest . -- --template svelte',
        'npm install',
        'npm run dev',
      ],
      files: [],
    ),
    TemplateEntity(
      id: 'angular-basic',
      name: 'Angular Basic',
      description: 'Aplicação Angular moderna',
      category: TemplateCategory.frontend,
      tags: ['angular', 'typescript', 'frontend', 'spa'],
      icon: '🔺',
      author: 'MobileVim',
      commands: [
        'npm install -g @angular/cli',
        'ng new mobilevim-app',
      ],
      files: [],
    ),
    TemplateEntity(
      id: 'golang-gin',
      name: 'Go Gin API',
      description: 'API REST com Go e Gin framework',
      category: TemplateCategory.backend,
      tags: ['golang', 'gin', 'api', 'backend'],
      icon: '🐹',
      author: 'MobileVim',
      commands: [
        'go mod init mobilevim/api',
        'go get -u github.com/gin-gonic/gin',
        'go run main.go',
      ],
      files: [
        const TemplateFile(
          path: 'main.go',
          content: '''package main

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

type User struct {
	ID    int    `json:"id"`
	Name  string `json:"name"`
	Email string `json:"email"`
}

var users = []User{
	{ID: 1, Name: "João Silva", Email: "joao@email.com"},
	{ID: 2, Name: "Maria Santos", Email: "maria@email.com"},
}

func main() {
	r := gin.Default()

	r.GET("/", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"message": "MobileVim Go Gin API",
			"docs":    "/api/health",
		})
	})

	r.GET("/api/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"status": "ok"})
	})

	r.GET("/api/users", func(c *gin.Context) {
		c.JSON(http.StatusOK, users)
	})

	r.GET("/api/users/:id", func(c *gin.Context) {
		id := c.Param("id")
		for _, u := range users {
			if string(rune(u.ID)) == id {
				c.JSON(http.StatusOK, u)
				return
			}
		}
		c.JSON(http.StatusNotFound, gin.H{"error": "Usuário não encontrado"})
	})

	r.POST("/api/users", func(c *gin.Context) {
		var user User
		if err := c.ShouldBindJSON(&user); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}
		user.ID = len(users) + 1
		users = append(users, user)
		c.JSON(http.StatusCreated, user)
	})

	r.Run(":8080")
}
''',
          description: 'Servidor Gin principal',
        ),
        const TemplateFile(
          path: 'go.mod',
          content: '''module mobilevim/api

go 1.21

require github.com/gin-gonic/gin v1.9.1
''',
          description: 'Módulo Go',
        ),
      ],
    ),
    TemplateEntity(
      id: 'remix-basic',
      name: 'Remix Basic',
      description: 'Full-stack web framework Remix',
      category: TemplateCategory.fullstack,
      tags: ['remix', 'react', 'fullstack', 'ssr'],
      icon: '💿',
      author: 'MobileVim',
      commands: [
        'npx create-remix@latest',
      ],
      files: [],
    ),
    TemplateEntity(
      id: 'astro-basic',
      name: 'Astro Basic',
      description: 'Site estático com Astro',
      category: TemplateCategory.frontend,
      tags: ['astro', 'static', 'ssg', 'frontend'],
      icon: '🚀',
      author: 'MobileVim',
      commands: [
        'npm create astro@latest',
      ],
      files: [],
    ),
  ];
}
