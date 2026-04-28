#!/usr/bin/env node

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
  ListResourcesRequestSchema,
  ReadResourceRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";
import { readFile, readdir, stat } from "fs/promises";
import { join } from "path";
import { homedir } from "os";

// Configuración de rutas de skills
const SKILLS_PATHS = [
  join(homedir(), ".agents", "skills"),
  join(homedir(), ".claude", "skills"),
];

interface SkillInfo {
  name: string;
  path: string;
  location: string;
}

interface SkillContent {
  name: string;
  path: string;
  content: string;
  size: number;
}

// Función para buscar todos los skills disponibles
async function findAllSkills(): Promise<SkillInfo[]> {
  const skills: SkillInfo[] = [];

  for (const basePath of SKILLS_PATHS) {
    try {
      const entries = await readdir(basePath, { withFileTypes: true });
      const location = basePath.includes(".agents") ? "project" : "user";

      for (const entry of entries) {
        if (entry.isDirectory()) {
          const skillPath = join(basePath, entry.name);
          const skillFile = join(skillPath, "SKILL.md");

          try {
            await stat(skillFile);
            skills.push({
              name: entry.name,
              path: skillFile,
              location,
            });
          } catch {
            // Si no existe SKILL.md, buscar otros archivos .md
            const files = await readdir(skillPath);
            const mdFile = files.find((f) => f.endsWith(".md"));
            if (mdFile) {
              skills.push({
                name: entry.name,
                path: join(skillPath, mdFile),
                location,
              });
            }
          }
        }
      }
    } catch (error) {
      // Directorio no existe o no es accesible
      console.error(`No se pudo acceder a ${basePath}:`, error);
    }
  }

  return skills;
}

// Función para leer el contenido de un skill
async function readSkillContent(skillPath: string): Promise<string> {
  try {
    const content = await readFile(skillPath, "utf-8");
    return content;
  } catch (error) {
    throw new Error(`No se pudo leer el skill: ${error}`);
  }
}

// Función para buscar skills por nombre o contenido
async function searchSkills(query: string): Promise<SkillInfo[]> {
  const allSkills = await findAllSkills();
  const results: SkillInfo[] = [];

  for (const skill of allSkills) {
    // Buscar en el nombre
    if (skill.name.toLowerCase().includes(query.toLowerCase())) {
      results.push(skill);
      continue;
    }

    // Buscar en el contenido
    try {
      const content = await readSkillContent(skill.path);
      if (content.toLowerCase().includes(query.toLowerCase())) {
        results.push(skill);
      }
    } catch {
      // Ignorar errores de lectura
    }
  }

  return results;
}

// Crear servidor MCP
const server = new Server(
  {
    name: "skills-reader",
    version: "1.0.0",
  },
  {
    capabilities: {
      tools: {},
      resources: {},
    },
  }
);

// Handler para listar herramientas disponibles
server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: [
      {
        name: "list_skills",
        description: "Lista todos los skills/agentes disponibles en ~/.agents/skills y ~/.claude/skills",
        inputSchema: {
          type: "object",
          properties: {},
        },
      },
      {
        name: "read_skill",
        description: "Lee el contenido completo de un skill específico por su nombre",
        inputSchema: {
          type: "object",
          properties: {
            skill_name: {
              type: "string",
              description: "Nombre del skill a leer (ej: 'sdd-apply', 'gitflow-feature')",
            },
          },
          required: ["skill_name"],
        },
      },
      {
        name: "search_skills",
        description: "Busca skills por nombre o contenido",
        inputSchema: {
          type: "object",
          properties: {
            query: {
              type: "string",
              description: "Término de búsqueda (busca en nombres y contenido)",
            },
          },
          required: ["query"],
        },
      },
      {
        name: "get_all_skills_content",
        description: "Obtiene el contenido de todos los skills de una vez (útil para contexto completo)",
        inputSchema: {
          type: "object",
          properties: {
            location: {
              type: "string",
              description: "Filtrar por ubicación: 'project' (~/.agents), 'user' (~/.claude), o 'all'",
              enum: ["project", "user", "all"],
            },
          },
        },
      },
    ],
  };
});

// Handler para ejecutar herramientas
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  try {
    switch (name) {
      case "list_skills": {
        const skills = await findAllSkills();
        const skillList = skills
          .map((s) => `📝 **${s.name}** (${s.location})\n   Path: ${s.path}`)
          .join("\n\n");

        return {
          content: [
            {
              type: "text",
              text: `# Skills Disponibles (${skills.length})\n\n${skillList || "No se encontraron skills"}`,
            },
          ],
        };
      }

      case "read_skill": {
        const skillName = (args as any).skill_name;
        if (!skillName) {
          throw new Error("Se requiere el parámetro 'skill_name'");
        }

        const skills = await findAllSkills();
        const skill = skills.find((s) => s.name === skillName);

        if (!skill) {
          return {
            content: [
              {
                type: "text",
                text: `❌ Skill '${skillName}' no encontrado.\n\nSkills disponibles:\n${skills.map((s) => `- ${s.name}`).join("\n")}`,
              },
            ],
          };
        }

        const content = await readSkillContent(skill.path);
        return {
          content: [
            {
              type: "text",
              text: `# Skill: ${skill.name}\n**Location:** ${skill.location}\n**Path:** ${skill.path}\n\n---\n\n${content}`,
            },
          ],
        };
      }

      case "search_skills": {
        const query = (args as any).query;
        if (!query) {
          throw new Error("Se requiere el parámetro 'query'");
        }

        const results = await searchSkills(query);
        if (results.length === 0) {
          return {
            content: [
              {
                type: "text",
                text: `❌ No se encontraron skills que coincidan con: "${query}"`,
              },
            ],
          };
        }

        const resultList = results
          .map((s) => `📝 **${s.name}** (${s.location})\n   Path: ${s.path}`)
          .join("\n\n");

        return {
          content: [
            {
              type: "text",
              text: `# Resultados de búsqueda: "${query}" (${results.length})\n\n${resultList}`,
            },
          ],
        };
      }

      case "get_all_skills_content": {
        const location = (args as any).location || "all";
        const allSkills = await findAllSkills();

        let filteredSkills = allSkills;
        if (location !== "all") {
          filteredSkills = allSkills.filter((s) => s.location === location);
        }

        const skillsContent: SkillContent[] = [];
        for (const skill of filteredSkills) {
          try {
            const content = await readSkillContent(skill.path);
            const stats = await stat(skill.path);
            skillsContent.push({
              name: skill.name,
              path: skill.path,
              content,
              size: stats.size,
            });
          } catch (error) {
            console.error(`Error leyendo ${skill.name}:`, error);
          }
        }

        const fullContent = skillsContent
          .map(
            (sc) =>
              `# ========================================\n# Skill: ${sc.name}\n# Location: ${sc.path}\n# Size: ${sc.size} bytes\n# ========================================\n\n${sc.content}\n\n`
          )
          .join("\n");

        return {
          content: [
            {
              type: "text",
              text: `# Todos los Skills (${skillsContent.length})\n\n${fullContent}`,
            },
          ],
        };
      }

      default:
        throw new Error(`Herramienta desconocida: ${name}`);
    }
  } catch (error) {
    return {
      content: [
        {
          type: "text",
          text: `❌ Error: ${error instanceof Error ? error.message : String(error)}`,
        },
      ],
      isError: true,
    };
  }
});

// Handler para listar recursos (alternativa a tools)
server.setRequestHandler(ListResourcesRequestSchema, async () => {
  const skills = await findAllSkills();

  return {
    resources: skills.map((skill) => ({
      uri: `skill:///${skill.name}`,
      name: skill.name,
      description: `Skill ubicado en ${skill.location}`,
      mimeType: "text/markdown",
    })),
  };
});

// Handler para leer recursos
server.setRequestHandler(ReadResourceRequestSchema, async (request) => {
  const uri = request.params.uri;
  const skillName = uri.replace("skill:///", "");

  const skills = await findAllSkills();
  const skill = skills.find((s) => s.name === skillName);

  if (!skill) {
    throw new Error(`Skill no encontrado: ${skillName}`);
  }

  const content = await readSkillContent(skill.path);

  return {
    contents: [
      {
        uri,
        mimeType: "text/markdown",
        text: content,
      },
    ],
  };
});

// Iniciar servidor
async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);

  console.error("Skills Reader MCP Server iniciado");
  console.error(`Leyendo skills de:`);
  for (const path of SKILLS_PATHS) {
    console.error(`  - ${path}`);
  }
}

main().catch((error) => {
  console.error("Error fatal:", error);
  process.exit(1);
});
