import { Controller } from "@hotwired/stimulus"

// Shows or hides the team limits on the new game form according to the
// selected rating system's supported format. Each rating system <option>
// carries data-fixed-teams / data-fixed-players-per-team when it allows only
// one value (e.g. Elo is always 2 teams of 1).
export default class extends Controller {
  static targets = [ "rating", "maxPlayers", "maxPlayersGroup", "maxTeams", "maxTeamsGroup" ]

  connect() {
    this.applyFormat()
  }

  handleRatingChange() {
    this.applyFormat()
  }

  applyFormat() {
    if (!this.hasRatingTarget) return

    const format = this.ratingTarget.selectedOptions[0].dataset
    this.applyLimit(format.fixedPlayersPerTeam, this.maxPlayersTarget, this.maxPlayersGroupTarget)
    this.applyLimit(format.fixedTeams, this.maxTeamsTarget, this.maxTeamsGroupTarget)
  }

  applyLimit(fixed, input, group) {
    if (fixed) {
      input.value = fixed
      group.style.display = 'none'
    } else {
      if (group.style.display === 'none') input.value = 2
      group.style.display = 'block'
    }
  }
}
