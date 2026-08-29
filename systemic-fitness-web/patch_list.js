const fs = require('fs');

let content = fs.readFileSync('src/app/(dashboard)/clients/page.tsx', 'utf8');

const search = `                {/* Subscription Badge */}
                {sub ? (
                  <div className={cn("hidden lg:flex items-center gap-2 px-3 py-1.5 rounded-lg shrink-0", tc?.bg)}>
                    {TierIcon && <TierIcon className={cn("h-3.5 w-3.5", tc?.color)} />}
                    <div className="text-right">
                      <p className={cn("text-xs font-semibold", tc?.color)}>{sub.plan_name}</p>
                      <p className="text-[10px] text-slate-400 flex items-center gap-0.5">
                        <Clock className="h-2.5 w-2.5" />
                        {daysLeft != null && daysLeft > 0
                          ? \`\${daysLeft} hari lagi\`
                          : "Expired"}
                      </p>
                    </div>
                  </div>
                ) : (
                  <span className="hidden lg:block text-xs text-slate-300 italic shrink-0">
                    No plan
                  </span>
                )}`;

const replace = `                {/* Classification Badge */}
                <div className="hidden lg:flex items-center shrink-0 w-24 justify-center">
                  {(client as any).classification ? (
                    <span className="px-3 py-1 rounded-full text-xs font-bold bg-indigo-100 text-indigo-700 uppercase tracking-wider">
                      {(client as any).classification}
                    </span>
                  ) : (
                    <span className="px-3 py-1 rounded-full text-xs font-medium bg-slate-100 text-slate-500 italic">
                      Unclassified
                    </span>
                  )}
                </div>`;

content = content.replace(search, replace);
fs.writeFileSync('src/app/(dashboard)/clients/page.tsx', content);
console.log("Patched page.tsx");
