FactoryBot.define { factory(:team) { players { [FactoryBot.build(:player)] } } }
