<cfoutput>
    <div>
        <select name="genre" onchange="document.location.href = '/beatbox/loops?genre=' + this.value">
            <option value="">-- Select genre --</option>
            <cfloop array="#genres#" index="genre">
                <option value="#genre#">#genre#</option>
            </cfloop>
        </select>
        <div class="mt-5 row">
            <cfloop array="#loops#" index="loop">
                <div class="col-md-4 mb-4">
                    <div class="card text-center">
                        <div class="card-body">
                            <h5 class="card-title">#loop.title#</h5>
                            <div class="card-text">
                                <p>#loop.description#</p>
                                <p>Genre: #loop.genre#</p>
                                <p>BPM: #loop.bpm#</p>
                            </div>

                            <button class="btn btn-primary btn-lg" onclick="playLoop('#loop.title#')">
                                <i class="fas fa-play-circle"></i> Play
                            </button>
                        </div>
                    </div>
                </div>
            </cfloop>
        </div>
    </div>
</cfoutput>