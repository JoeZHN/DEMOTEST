extends RefCounted
class_name BattleLoader

static func load_test_battle_config() -> Dictionary:
	return {
		"battle_id": "test_battle_001",
		"battle_name": "Battle Framework Test",
		"units": [
			{
				"unit_id": "player_huchao",
				"display_name": "胡超",
				"camp": "player",
				"initiative": 10
			},
			{
				"unit_id": "player_spearman",
				"display_name": "枪兵队友",
				"camp": "player",
				"initiative": 8
			},
			{
				"unit_id": "player_archer",
				"display_name": "弓手队友",
				"camp": "player",
				"initiative": 12
			},
			{
				"unit_id": "enemy_raider",
				"display_name": "敌兵",
				"camp": "enemy",
				"initiative": 9
			}
		]
	}
