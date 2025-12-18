import React, { useState, useEffect, useRef } from 'react';

const Onboarding03_BirthData = () => {
    const [showContent, setShowContent] = useState(false);
    const [birthDate, setBirthDate] = useState({ month: 'January', day: 15, year: 1995 });
    const [birthTime, setBirthTime] = useState({ hour: 12, minute: 0, period: 'PM' });
    const [location, setLocation] = useState('');
    const [activeField, setActiveField] = useState(null);
    const [showWhyModal, setShowWhyModal] = useState(false);

    useEffect(() => {
        setTimeout(() => setShowContent(true), 300);
    }, []);

    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    const days = Array.from({ length: 31 }, (_, i) => i + 1);
    const years = Array.from({ length: 80 }, (_, i) => 2010 - i);
    const hours = Array.from({ length: 12 }, (_, i) => i + 1);
    const minutes = Array.from({ length: 60 }, (_, i) => i);

    const isComplete = birthDate.month && birthDate.day && birthDate.year && location.length > 2;

    const WheelPicker = ({ items, selectedValue, onSelect, formatValue }) => {
        const scrollRef = useRef(null);
        const itemHeight = 44;

        useEffect(() => {
            if (scrollRef.current) {
                const index = items.indexOf(selectedValue);
                scrollRef.current.scrollTop = index * itemHeight;
            }
        }, []);

        const handleScroll = () => {
            if (scrollRef.current) {
                const index = Math.round(scrollRef.current.scrollTop / itemHeight);
                if (items[index] !== selectedValue) {
                    onSelect(items[index]);
                }
            }
        };

        return (
            <div style={{ position: 'relative', height: '180px', overflow: 'hidden' }}>
                <div style={{
                    position: 'absolute',
                    top: '50%',
                    left: 0,
                    right: 0,
                    height: '44px',
                    transform: 'translateY(-50%)',
                    background: 'rgba(250, 255, 14, 0.1)',
                    borderTop: '1px solid rgba(250, 255, 14, 0.3)',
                    borderBottom: '1px solid rgba(250, 255, 14, 0.3)',
                    pointerEvents: 'none',
                    zIndex: 1,
                }} />
                <div style={{
                    position: 'absolute',
                    top: 0,
                    left: 0,
                    right: 0,
                    height: '68px',
                    background: 'linear-gradient(to bottom, #1a1a24, transparent)',
                    pointerEvents: 'none',
                    zIndex: 2,
                }} />
                <div style={{
                    position: 'absolute',
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: '68px',
                    background: 'linear-gradient(to top, #1a1a24, transparent)',
                    pointerEvents: 'none',
                    zIndex: 2,
                }} />
                <div
                    ref={scrollRef}
                    onScroll={handleScroll}
                    style={{
                        height: '100%',
                        overflowY: 'scroll',
                        scrollSnapType: 'y mandatory',
                        paddingTop: '68px',
                        paddingBottom: '68px',
                    }}
                >
                    {items.map((item, index) => (
                        <div
                            key={index}
                            onClick={() => onSelect(item)}
                            style={{
                                height: `${itemHeight}px`,
                                display: 'flex',
                                alignItems: 'center',
                                justifyContent: 'center',
                                scrollSnapAlign: 'center',
                                fontSize: '20px',
                                fontWeight: item === selectedValue ? 600 : 400,
                                color: item === selectedValue ? '#FAFF0E' : 'rgba(255,255,255,0.4)',
                                cursor: 'pointer',
                                transition: 'all 0.2s ease',
                            }}
                        >
                            {formatValue ? formatValue(item) : item}
                        </div>
                    ))}
                </div>
            </div>
        );
    };

    return (
        <div style={{
            minHeight: '100vh',
            background: 'linear-gradient(180deg, #0A0A0F 0%, #0D0D15 50%, #12101A 100%)',
            fontFamily: "'Syne', sans-serif",
            color: '#FFFFFF',
            position: 'relative',
            overflow: 'hidden',
            display: 'flex',
            flexDirection: 'column',
        }}>
            <style>{`
        @import url('https://fonts.googleapis.com/css2?family=Syne:wght@400;500;600;700;800&family=Space+Grotesk:wght@300;400;500&display=swap');
        
        @keyframes pulse { 0%, 100% { opacity: 0.5; } 50% { opacity: 0.8; } }
        @keyframes float { 0%, 100% { transform: translateY(0); } 50% { transform: translateY(-8px); } }
        @keyframes slideUp { from { transform: translateY(100%); } to { transform: translateY(0); } }
        @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }
        
        .input-tile { transition: all 0.3s ease; cursor: pointer; }
        .input-tile:hover { background: rgba(255, 255, 255, 0.06); }
        .input-tile.active { border-color: #FAFF0E; background: rgba(250, 255, 14, 0.05); }
        
        .cta-button { transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1); }
        .cta-button:hover:not(:disabled) { transform: translateY(-4px); box-shadow: 0 20px 50px rgba(250, 255, 14, 0.4); }
        
        .modal-overlay { animation: fadeIn 0.3s ease; }
        .modal-content { animation: slideUp 0.4s cubic-bezier(0.4, 0, 0.2, 1); }
      `}</style>

            {/* Background */}
            <div style={{
                position: 'absolute',
                top: '30%',
                left: '50%',
                transform: 'translateX(-50%)',
                width: '400px',
                height: '400px',
                background: 'radial-gradient(circle, rgba(125, 103, 254, 0.1) 0%, transparent 60%)',
                borderRadius: '50%',
                filter: 'blur(60px)',
                animation: 'pulse 10s ease-in-out infinite',
            }} />

            {/* Date Picker Modal */}
            {activeField === 'date' && (
                <div className="modal-overlay" onClick={() => setActiveField(null)} style={{
                    position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.8)', zIndex: 100,
                    display: 'flex', alignItems: 'flex-end', justifyContent: 'center',
                }}>
                    <div className="modal-content" onClick={(e) => e.stopPropagation()} style={{
                        width: '100%', maxWidth: '420px', background: '#1a1a24',
                        borderRadius: '24px 24px 0 0', padding: '20px', paddingBottom: '40px',
                    }}>
                        <div style={{ width: '40px', height: '4px', background: 'rgba(255,255,255,0.2)', borderRadius: '2px', margin: '0 auto 20px' }} />
                        <h3 style={{ textAlign: 'center', fontSize: '18px', fontWeight: 700, marginBottom: '20px' }}>Select Birth Date</h3>
                        <div style={{ display: 'flex', gap: '8px' }}>
                            <div style={{ flex: 1.2 }}>
                                <WheelPicker items={months} selectedValue={birthDate.month} onSelect={(v) => setBirthDate({ ...birthDate, month: v })} />
                            </div>
                            <div style={{ flex: 0.6 }}>
                                <WheelPicker items={days} selectedValue={birthDate.day} onSelect={(v) => setBirthDate({ ...birthDate, day: v })} />
                            </div>
                            <div style={{ flex: 0.8 }}>
                                <WheelPicker items={years} selectedValue={birthDate.year} onSelect={(v) => setBirthDate({ ...birthDate, year: v })} />
                            </div>
                        </div>
                        <button onClick={() => setActiveField(null)} style={{
                            width: '100%', background: 'linear-gradient(135deg, #FAFF0E 0%, #E5EB0D 100%)',
                            border: 'none', borderRadius: '16px', padding: '16px', marginTop: '20px',
                            fontSize: '16px', fontWeight: 700, color: '#0A0A0F', cursor: 'pointer',
                        }}>Done</button>
                    </div>
                </div>
            )}

            {/* Time Picker Modal */}
            {activeField === 'time' && (
                <div className="modal-overlay" onClick={() => setActiveField(null)} style={{
                    position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.8)', zIndex: 100,
                    display: 'flex', alignItems: 'flex-end', justifyContent: 'center',
                }}>
                    <div className="modal-content" onClick={(e) => e.stopPropagation()} style={{
                        width: '100%', maxWidth: '420px', background: '#1a1a24',
                        borderRadius: '24px 24px 0 0', padding: '20px', paddingBottom: '40px',
                    }}>
                        <div style={{ width: '40px', height: '4px', background: 'rgba(255,255,255,0.2)', borderRadius: '2px', margin: '0 auto 20px' }} />
                        <h3 style={{ textAlign: 'center', fontSize: '18px', fontWeight: 700, marginBottom: '20px' }}>Select Birth Time</h3>
                        <div style={{ display: 'flex', gap: '8px' }}>
                            <div style={{ flex: 1 }}>
                                <WheelPicker items={hours} selectedValue={birthTime.hour} onSelect={(v) => setBirthTime({ ...birthTime, hour: v })} />
                            </div>
                            <div style={{ flex: 1 }}>
                                <WheelPicker items={minutes} selectedValue={birthTime.minute} onSelect={(v) => setBirthTime({ ...birthTime, minute: v })} formatValue={(v) => v.toString().padStart(2, '0')} />
                            </div>
                            <div style={{ flex: 0.8 }}>
                                <WheelPicker items={['AM', 'PM']} selectedValue={birthTime.period} onSelect={(v) => setBirthTime({ ...birthTime, period: v })} />
                            </div>
                        </div>
                        <button onClick={() => setActiveField(null)} style={{
                            width: '100%', background: 'linear-gradient(135deg, #FAFF0E 0%, #E5EB0D 100%)',
                            border: 'none', borderRadius: '16px', padding: '16px', marginTop: '20px',
                            fontSize: '16px', fontWeight: 700, color: '#0A0A0F', cursor: 'pointer',
                        }}>Done</button>
                    </div>
                </div>
            )}

            {/* Why Modal */}
            {showWhyModal && (
                <div className="modal-overlay" onClick={() => setShowWhyModal(false)} style={{
                    position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.8)', zIndex: 100,
                    display: 'flex', alignItems: 'center', justifyContent: 'center', padding: '20px',
                }}>
                    <div className="modal-content" onClick={(e) => e.stopPropagation()} style={{
                        width: '100%', maxWidth: '360px', background: '#1a1a24',
                        borderRadius: '24px', padding: '28px', border: '1px solid rgba(255,255,255,0.1)',
                    }}>
                        <h3 style={{ fontSize: '20px', fontWeight: 700, marginBottom: '20px', textAlign: 'center' }}>Why we need this</h3>

                        {[
                            {
                                icon: (
                                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
                                        <circle cx="12" cy="12" r="8" stroke="#FAFF0E" strokeWidth="1.5" fill="none" />
                                        <circle cx="12" cy="12" r="2" fill="#FAFF0E" />
                                        <ellipse cx="12" cy="12" rx="8" ry="3" stroke="#FAFF0E" strokeWidth="1" fill="none" opacity="0.5" />
                                    </svg>
                                ), title: 'Planetary Positions', desc: 'Calculate where planets were at your birth'
                            },
                            {
                                icon: (
                                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
                                        <path d="M4 20h16" stroke="#FF59D0" strokeWidth="1.5" strokeLinecap="round" />
                                        <path d="M8 20c0-4 2-8 4-8s4 4 4 8" stroke="#FF59D0" strokeWidth="1.5" fill="none" />
                                        <path d="M12 4v4M16 6l-2 2M8 6l2 2" stroke="#FF59D0" strokeWidth="1.5" strokeLinecap="round" />
                                    </svg>
                                ), title: 'Rising Sign', desc: 'Your ascendant needs exact birth time & place'
                            },
                            {
                                icon: (
                                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
                                        <path d="M4 12L10 6L16 18L22 8" stroke="#7D67FE" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" />
                                        <circle cx="10" cy="6" r="2" fill="#7D67FE" opacity="0.5" />
                                        <circle cx="16" cy="18" r="2" fill="#7D67FE" opacity="0.5" />
                                    </svg>
                                ), title: 'Unique Sound', desc: 'Generate your one-of-a-kind frequency'
                            },
                        ].map((item, i) => (
                            <div key={i} style={{ display: 'flex', gap: '14px', marginBottom: i < 2 ? '16px' : 0 }}>
                                <div style={{
                                    width: '44px', height: '44px', borderRadius: '12px',
                                    background: 'rgba(255,255,255,0.05)', display: 'flex',
                                    alignItems: 'center', justifyContent: 'center', flexShrink: 0,
                                }}>{item.icon}</div>
                                <div>
                                    <h4 style={{ fontSize: '14px', fontWeight: 600, margin: '0 0 4px 0' }}>{item.title}</h4>
                                    <p style={{ fontSize: '13px', color: 'rgba(255,255,255,0.5)', margin: 0 }}>{item.desc}</p>
                                </div>
                            </div>
                        ))}

                        <button onClick={() => setShowWhyModal(false)} style={{
                            width: '100%', background: 'rgba(255,255,255,0.1)', border: 'none',
                            borderRadius: '12px', padding: '14px', marginTop: '24px',
                            fontSize: '14px', fontWeight: 600, color: 'white', cursor: 'pointer',
                        }}>Got it</button>
                    </div>
                </div>
            )}

            {/* Main Container */}
            <div style={{
                maxWidth: '420px', margin: '0 auto', padding: '20px',
                position: 'relative', zIndex: 10, flex: 1, display: 'flex', flexDirection: 'column',
            }}>
                {/* Header */}
                <div style={{
                    display: 'flex', justifyContent: 'space-between', alignItems: 'center',
                    padding: '16px 0', opacity: showContent ? 1 : 0, transition: 'opacity 0.5s ease',
                }}>
                    <button style={{
                        background: 'rgba(255, 255, 255, 0.05)', border: 'none',
                        borderRadius: '12px', padding: '10px', cursor: 'pointer',
                    }}>
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2" strokeLinecap="round">
                            <path d="M19 12H5M12 19l-7-7 7-7" />
                        </svg>
                    </button>
                    <span style={{ fontSize: '13px', color: 'rgba(255,255,255,0.4)', fontFamily: "'Space Grotesk', sans-serif" }}>Step 2 of 9</span>
                    <div style={{ width: '40px' }} />
                </div>

                {/* Content */}
                <div style={{
                    flex: 1, display: 'flex', flexDirection: 'column', paddingTop: '20px',
                    opacity: showContent ? 1 : 0, transform: showContent ? 'translateY(0)' : 'translateY(20px)',
                    transition: 'all 0.8s cubic-bezier(0.4, 0, 0.2, 1)',
                }}>
                    {/* Planet Icon */}
                    <div style={{
                        width: '80px', height: '80px', margin: '0 auto 28px',
                        animation: 'float 4s ease-in-out infinite',
                    }}>
                        <svg width="80" height="80" viewBox="0 0 80 80" fill="none">
                            <defs>
                                <linearGradient id="planetGrad" x1="0%" y1="0%" x2="100%" y2="100%">
                                    <stop offset="0%" stopColor="#7D67FE" />
                                    <stop offset="100%" stopColor="#FF59D0" />
                                </linearGradient>
                            </defs>
                            <circle cx="40" cy="40" r="24" stroke="url(#planetGrad)" strokeWidth="2" fill="none" />
                            <ellipse cx="40" cy="40" rx="35" ry="10" stroke="url(#planetGrad)" strokeWidth="1.5" fill="none" transform="rotate(-20 40 40)" />
                            <circle cx="40" cy="40" r="8" fill="url(#planetGrad)" opacity="0.3" />
                            <circle cx="40" cy="40" r="4" fill="url(#planetGrad)" />
                            <circle cx="62" cy="28" r="3" fill="#FAFF0E" />
                        </svg>
                    </div>

                    <h1 style={{ fontSize: '28px', fontWeight: 700, margin: '0 0 12px 0', textAlign: 'center' }}>When were you born?</h1>
                    <p style={{ fontSize: '15px', color: 'rgba(255,255,255,0.5)', margin: '0 0 8px 0', textAlign: 'center', fontFamily: "'Space Grotesk', sans-serif" }}>
                        We'll map your exact planetary positions
                    </p>

                    <button onClick={() => setShowWhyModal(true)} style={{
                        background: 'none', border: 'none', color: '#7D67FE',
                        fontSize: '13px', fontWeight: 600, cursor: 'pointer', marginBottom: '32px',
                        display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '6px',
                    }}>
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                            <circle cx="12" cy="12" r="10" /><path d="M12 16v-4M12 8h.01" />
                        </svg>
                        Why do we need this?
                    </button>

                    {/* Input Tiles */}
                    <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
                        {/* Date */}
                        <div className={`input-tile ${activeField === 'date' ? 'active' : ''}`} onClick={() => setActiveField('date')} style={{
                            background: 'rgba(255, 255, 255, 0.03)', border: '1px solid rgba(255, 255, 255, 0.08)',
                            borderRadius: '16px', padding: '16px 20px', display: 'flex', alignItems: 'center', gap: '16px',
                        }}>
                            <div style={{ width: '44px', height: '44px', borderRadius: '12px', background: 'rgba(250, 255, 14, 0.1)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                                <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
                                    <rect x="3" y="4" width="18" height="18" rx="4" stroke="#FAFF0E" strokeWidth="1.5" fill="none" />
                                    <path d="M3 9h18" stroke="#FAFF0E" strokeWidth="1.5" />
                                    <path d="M8 2v4M16 2v4" stroke="#FAFF0E" strokeWidth="1.5" strokeLinecap="round" />
                                    <circle cx="12" cy="15" r="2" fill="#FAFF0E" />
                                </svg>
                            </div>
                            <div style={{ flex: 1 }}>
                                <p style={{ fontSize: '12px', color: 'rgba(255,255,255,0.4)', margin: '0 0 4px 0' }}>Birth Date</p>
                                <p style={{ fontSize: '16px', fontWeight: 600, margin: 0 }}>{birthDate.month} {birthDate.day}, {birthDate.year}</p>
                            </div>
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,0.3)" strokeWidth="2"><path d="M9 18l6-6-6-6" /></svg>
                        </div>

                        {/* Time */}
                        <div className={`input-tile ${activeField === 'time' ? 'active' : ''}`} onClick={() => setActiveField('time')} style={{
                            background: 'rgba(255, 255, 255, 0.03)', border: '1px solid rgba(255, 255, 255, 0.08)',
                            borderRadius: '16px', padding: '16px 20px', display: 'flex', alignItems: 'center', gap: '16px',
                        }}>
                            <div style={{ width: '44px', height: '44px', borderRadius: '12px', background: 'rgba(255, 89, 208, 0.1)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                                <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
                                    <circle cx="12" cy="12" r="9" stroke="#FF59D0" strokeWidth="1.5" fill="none" />
                                    <path d="M12 6v6l4 2" stroke="#FF59D0" strokeWidth="1.5" strokeLinecap="round" />
                                    <circle cx="12" cy="12" r="2" fill="#FF59D0" />
                                </svg>
                            </div>
                            <div style={{ flex: 1 }}>
                                <p style={{ fontSize: '12px', color: 'rgba(255,255,255,0.4)', margin: '0 0 4px 0' }}>Birth Time</p>
                                <p style={{ fontSize: '16px', fontWeight: 600, margin: 0 }}>{birthTime.hour}:{birthTime.minute.toString().padStart(2, '0')} {birthTime.period}</p>
                            </div>
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,0.3)" strokeWidth="2"><path d="M9 18l6-6-6-6" /></svg>
                        </div>

                        {/* Location */}
                        <div className="input-tile" style={{
                            background: 'rgba(255, 255, 255, 0.03)', border: '1px solid rgba(255, 255, 255, 0.08)',
                            borderRadius: '16px', padding: '16px 20px', display: 'flex', alignItems: 'center', gap: '16px',
                        }}>
                            <div style={{ width: '44px', height: '44px', borderRadius: '12px', background: 'rgba(125, 103, 254, 0.1)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                                <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
                                    <path d="M12 2C8 2 5 5.5 5 9.5C5 14.5 12 22 12 22C12 22 19 14.5 19 9.5C19 5.5 16 2 12 2Z" stroke="#7D67FE" strokeWidth="1.5" fill="none" />
                                    <circle cx="12" cy="9.5" r="2.5" fill="#7D67FE" />
                                </svg>
                            </div>
                            <div style={{ flex: 1 }}>
                                <p style={{ fontSize: '12px', color: 'rgba(255,255,255,0.4)', margin: '0 0 4px 0' }}>Birth Location</p>
                                <input
                                    type="text"
                                    placeholder="City, Country"
                                    value={location}
                                    onChange={(e) => setLocation(e.target.value)}
                                    style={{
                                        width: '100%', background: 'transparent', border: 'none', outline: 'none',
                                        fontSize: '16px', fontWeight: 600, color: 'white', fontFamily: "'Syne', sans-serif",
                                    }}
                                />
                            </div>
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,0.3)" strokeWidth="2">
                                <circle cx="11" cy="11" r="8" /><path d="M21 21l-4.35-4.35" />
                            </svg>
                        </div>
                    </div>
                </div>

                {/* CTA */}
                <div style={{ padding: '20px 0 40px', opacity: showContent ? 1 : 0, transition: 'opacity 0.5s ease 0.3s' }}>
                    <button className="cta-button" disabled={!isComplete} style={{
                        width: '100%',
                        background: isComplete ? 'linear-gradient(135deg, #FAFF0E 0%, #E5EB0D 100%)' : 'rgba(255, 255, 255, 0.1)',
                        border: 'none', borderRadius: '16px', padding: '18px 32px',
                        fontSize: '16px', fontWeight: 700, fontFamily: "'Syne', sans-serif",
                        color: isComplete ? '#0A0A0F' : 'rgba(255,255,255,0.3)',
                        cursor: isComplete ? 'pointer' : 'not-allowed',
                        boxShadow: isComplete ? '0 10px 40px rgba(250, 255, 14, 0.3)' : 'none',
                        display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '10px',
                    }}>
                        Continue
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round"><path d="M5 12h14M12 5l7 7-7 7" /></svg>
                    </button>
                </div>
            </div>
        </div>
    );
};

export default Onboarding03_BirthData;