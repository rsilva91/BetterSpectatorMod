UPDATE Boosts SET Unit1Type = NULL, BoostClass = 'BOOST_TRIGGER_NONE_LATE_GAME_CRITICAL_TECH' WHERE TechnologyType = 'TECH_WRITING';

INSERT INTO Modifiers(ModifierId, ModifierType) VALUES
	('BSM_WRITING_BOOST', 'MODIFIER_PLAYER_GRANT_SPECIFIC_TECH_BOOST');

UPDATE Modifiers SET RunOnce = "1", Permanent = "1" WHERE ModifierId = 'BSM_WRITING_BOOST';

INSERT INTO ModifierArguments(ModifierId, Name, Value) VALUES
	('BSM_WRITING_BOOST', 'TechType', 'TECH_WRITING');