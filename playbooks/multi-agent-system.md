# Playbook: Multi-Agent Systems

> Patterns from a production content pipeline with 5 autonomous agents.

## 1. Match Model to Task

Not every agent needs the most powerful model. Match capability to requirement.

| Agent Role | Model | Why |
|-----------|-------|-----|
| Orchestrator/Lead | Opus | Needs judgment, delegation, context synthesis |
| Writer | Opus | Voice fidelity, creative quality |
| Researcher | Sonnet | Information gathering, summarization |
| Poster/Publisher | Sonnet | Template-following, formatting |
| Analyst | Sonnet | Data extraction, structured output |

```json
{
  "agents": {
    "lead": {
      "model": "claude-opus-4-6",
      "allowAgents": ["researcher", "writer", "poster"],
      "instructions": "You orchestrate the content pipeline..."
    },
    "researcher": {
      "model": "claude-sonnet-4-6",
      "allowAgents": [],
      "instructions": "You research topics and return findings..."
    },
    "writer": {
      "model": "claude-opus-4-6",
      "allowAgents": [],
      "instructions": "You write content matching the brand voice..."
    }
  }
}
```

## 2. Delegation Control at Config Level

**Problem**: Telling an agent "don't delegate" in its prompt doesn't work — LLMs are unreliable prompt followers.

**Solution**: Set `allowAgents: []` in the config. The agent literally cannot delegate.

```json
// ❌ Prompt-level restriction (unreliable)
{
  "instructions": "Never delegate to other agents. Always return findings directly."
}

// ✅ Config-level restriction (enforced by system)
{
  "allowAgents": [],
  "instructions": "Research the topic and return your findings."
}
```

## 3. Cost Guard Rails on Orchestrator

The orchestrator controls spend. Put limits here, not on leaf agents.

```
Rules for the lead agent:
- One writer call per topic (no rewrites via re-delegation)
- Maximum 3 writer calls per pipeline run
- Researcher returns findings to you — synthesize before sending to writer
- If a deliverable is produced, pipeline is DONE — do not iterate
```

## 4. Session Management

**Problem**: Behavioral changes to agent prompts don't take effect because old session history overrides new instructions.

**Solution**: Clear session files when changing behavior.

```bash
# Clear all agent sessions (forces fresh start)
rm -f sessions/*.jsonl sessions/*.lock

# Or clear weekly via environment variable
export CLEAR_SESSIONS_WEEKLY=1  # Auto-prune sessions >7 days on deploy
```

## 5. Key Rules

- **Never `kill -HUP` the gateway process** — it dies. Redeploy instead.
- **No bash code blocks in agent prompts** — LLMs try to execute them. Use plain text.
- **Clear `.lock` files alongside `.jsonl`** when wiping sessions.
- **Don't add unknown config keys** — strict config parsers will reject the entire config.
- **502 recovery**: Redeploy the service. Don't debug the dead process.
- **Prompt instructions can't override tool schemas** — disable tools at config level.
