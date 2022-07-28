<cfoutput>
    <div>
        <div>
            Last typing: <span class="fw-bold">#dateTimeFormat( args.lastTyping, "full" )#</span>
        </div>
        <div class="mt-4">
            <label class="w-100">
                I'll update the time as you type ANY KEY.
                <div class="mt-4">
                    <textarea wire:keydown="updateTime" class="w-100"></textarea>
                </div>
            </label>
        </div>
        <div class="mt-4">
            <labe class="w-100">
                I'll update the time only when you hit ENTER.
                <div class="mt-4">
                    <textarea wire:keydown.enter="updateTime" class="w-100"></textarea>
                </div>
            </label>
        </div>

    </div>
</cfoutput>