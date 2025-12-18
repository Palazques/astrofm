import React, { useState, useEffect } from 'react';

const Onboarding02_Name = () => {
    const [showContent, setShowContent] = useState(false);
    const [name, setName] = useState('');

    useEffect(() => {
        setTimeout(() => setShowContent(true), 300);
    }, []);

    // Dynamic gradient based on name length
    const getGradient = () => {
        const gradients = [
            'linear-gradient(135deg, #FF59D0 0%, #7D67FE 100%)',
            'linear-gradient(135deg, #7D67FE 0%, #00D4AA 100%)',
            'linear-gradient(135deg, #00D4AA 0%, #FAFF0E 100%)',
            'linear-gradient(135deg, #FAFF0E 0%, #FF59D0 100%)',
        ];
        return gradients[name.length % 4];
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
        
        @keyframes pulse {
          0%, 100% { opacity: 0.5; transform: scale(1); }
          50% { opacity: 0.8; transform: scale(1.05); }
        }
        
        @keyframes float {
          0%, 100% { transform: translateY(0); }
          50% { transform: translateY(-10px); }
        }
        
        @keyframes rotateRing {
          0% { transform: rotate(0deg); }
          100% { transform: rotate(360deg); }
        }
        
        @keyframes glow {
          0%, 100% { box-shadow: 0 0 20px rgba(250, 255, 14, 0.3); }
          50% { box-shadow: 0 0 40px rgba(250, 255, 14, 0.5); }
        }
        
        .preview-orb {
          transition: all 0.5s cubic-bezier(0.4, 0, 0.2, 1);
          animation: float 6s ease-in-out infinite;
        }
        
        .input-field {
          transition: all 0.3s ease;
        }
        
        .input-field:focus {
          border-color: #FAFF0E;
          box-shadow: 0 0 0 4px rgba(250, 255, 14, 0.1);
        }
        
        .cta-button {
          transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }
        
        .cta-button:hover:not(:disabled) {
          transform: translateY(-4px);
          box-shadow: 0 20px 50px rgba(250, 255, 14, 0.4);
        }
      `}</style>

            {/* Background Elements */}
            <div style={{
                position: 'absolute',
                top: '20%',
                left: '-20%',
                width: '400px',
                height: '400px',
                background: 'radial-gradient(circle, rgba(255, 89, 208, 0.1) 0%, transparent 60%)',
                borderRadius: '50%',
                filter: 'blur(60px)',
                animation: 'pulse 10s ease-in-out infinite',
            }} />

            {/* Main Container */}
            <div style={{
                maxWidth: '420px',
                margin: '0 auto',
                padding: '20px',
                position: 'relative',
                zIndex: 10,
                flex: 1,
                display: 'flex',
                flexDirection: 'column',
            }}>

                {/* Header */}
                <div style={{
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'center',
                    padding: '16px 0',
                    opacity: showContent ? 1 : 0,
                    transition: 'opacity 0.5s ease',
                }}>
                    <button style={{
                        background: 'rgba(255, 255, 255, 0.05)',
                        border: 'none',
                        borderRadius: '12px',
                        padding: '10px',
                        cursor: 'pointer',
                    }}>
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                            <path d="M19 12H5M12 19l-7-7 7-7" />
                        </svg>
                    </button>

                    <span style={{
                        fontSize: '13px',
                        color: 'rgba(255,255,255,0.4)',
                        fontFamily: "'Space Grotesk', sans-serif",
                    }}>Step 1 of 9</span>

                    <div style={{ width: '40px' }} />
                </div>

                {/* Content */}
                <div style={{
                    flex: 1,
                    display: 'flex',
                    flexDirection: 'column',
                    alignItems: 'center',
                    paddingTop: '40px',
                    opacity: showContent ? 1 : 0,
                    transform: showContent ? 'translateY(0)' : 'translateY(20px)',
                    transition: 'all 0.8s cubic-bezier(0.4, 0, 0.2, 1)',
                }}>

                    {/* Preview Orb */}
                    <div
                        className="preview-orb"
                        style={{
                            width: '140px',
                            height: '140px',
                            borderRadius: '50%',
                            background: getGradient(),
                            display: 'flex',
                            alignItems: 'center',
                            justifyContent: 'center',
                            marginBottom: '40px',
                            position: 'relative',
                            boxShadow: '0 20px 60px rgba(255, 89, 208, 0.3)',
                        }}
                    >
                        {/* Orbital ring */}
                        <div style={{
                            position: 'absolute',
                            inset: '-15px',
                            border: '1px solid rgba(255, 255, 255, 0.15)',
                            borderRadius: '50%',
                            animation: 'rotateRing 15s linear infinite',
                        }}>
                            <div style={{
                                position: 'absolute',
                                top: '-4px',
                                left: '50%',
                                width: '8px',
                                height: '8px',
                                borderRadius: '50%',
                                background: '#FAFF0E',
                                boxShadow: '0 0 10px #FAFF0E',
                            }} />
                        </div>

                        {/* User Icon or Initial */}
                        {name ? (
                            <span style={{
                                fontSize: '48px',
                                fontWeight: 800,
                                color: 'white',
                                textShadow: '0 2px 10px rgba(0,0,0,0.3)',
                            }}>
                                {name[0].toUpperCase()}
                            </span>
                        ) : (
                            <svg width="56" height="56" viewBox="0 0 56 56" fill="none">
                                <circle cx="28" cy="20" r="10" stroke="rgba(255,255,255,0.8)" strokeWidth="2" fill="none" />
                                <path d="M10 48c0-10 8-16 18-16s18 6 18 16" stroke="rgba(255,255,255,0.8)" strokeWidth="2" fill="none" strokeLinecap="round" />
                            </svg>
                        )}
                    </div>

                    {/* Title */}
                    <h1 style={{
                        fontSize: '28px',
                        fontWeight: 700,
                        margin: '0 0 12px 0',
                        textAlign: 'center',
                    }}>What's your name?</h1>

                    <p style={{
                        fontSize: '15px',
                        color: 'rgba(255,255,255,0.5)',
                        margin: '0 0 40px 0',
                        textAlign: 'center',
                        fontFamily: "'Space Grotesk', sans-serif",
                    }}>This is how you'll appear to friends</p>

                    {/* Input Field */}
                    <div style={{ width: '100%', marginBottom: '16px' }}>
                        <input
                            className="input-field"
                            type="text"
                            placeholder="Enter your name"
                            value={name}
                            onChange={(e) => setName(e.target.value.slice(0, 20))}
                            style={{
                                width: '100%',
                                background: 'rgba(255, 255, 255, 0.05)',
                                border: '1px solid rgba(255, 255, 255, 0.1)',
                                borderRadius: '16px',
                                padding: '18px 20px',
                                fontSize: '18px',
                                fontWeight: 500,
                                fontFamily: "'Syne', sans-serif",
                                color: 'white',
                                outline: 'none',
                                textAlign: 'center',
                                boxSizing: 'border-box',
                            }}
                        />
                        <div style={{
                            display: 'flex',
                            justifyContent: 'flex-end',
                            marginTop: '8px',
                        }}>
                            <span style={{
                                fontSize: '12px',
                                color: 'rgba(255,255,255,0.3)',
                                fontFamily: "'Space Grotesk', sans-serif",
                            }}>{name.length}/20</span>
                        </div>
                    </div>

                    {/* Preview Text */}
                    {name.length >= 2 && (
                        <div style={{
                            background: 'rgba(255, 255, 255, 0.03)',
                            border: '1px solid rgba(255, 255, 255, 0.08)',
                            borderRadius: '12px',
                            padding: '12px 20px',
                            marginTop: '8px',
                        }}>
                            <p style={{
                                fontSize: '14px',
                                color: 'rgba(255,255,255,0.6)',
                                margin: 0,
                                fontFamily: "'Space Grotesk', sans-serif",
                            }}>
                                Your cosmic profile: <span style={{ color: '#FAFF0E', fontWeight: 600 }}>{name}'s Sound</span>
                            </p>
                        </div>
                    )}
                </div>

                {/* CTA Button */}
                <div style={{
                    padding: '20px 0 40px',
                    opacity: showContent ? 1 : 0,
                    transition: 'opacity 0.5s ease 0.3s',
                }}>
                    <button
                        className="cta-button"
                        disabled={name.length < 2}
                        style={{
                            width: '100%',
                            background: name.length >= 2
                                ? 'linear-gradient(135deg, #FAFF0E 0%, #E5EB0D 100%)'
                                : 'rgba(255, 255, 255, 0.1)',
                            border: 'none',
                            borderRadius: '16px',
                            padding: '18px 32px',
                            fontSize: '16px',
                            fontWeight: 700,
                            fontFamily: "'Syne', sans-serif",
                            color: name.length >= 2 ? '#0A0A0F' : 'rgba(255,255,255,0.3)',
                            cursor: name.length >= 2 ? 'pointer' : 'not-allowed',
                            boxShadow: name.length >= 2 ? '0 10px 40px rgba(250, 255, 14, 0.3)' : 'none',
                            display: 'flex',
                            alignItems: 'center',
                            justifyContent: 'center',
                            gap: '10px',
                        }}
                    >
                        Continue
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
                            <path d="M5 12h14M12 5l7 7-7 7" />
                        </svg>
                    </button>
                </div>
            </div>
        </div>
    );
};

export default Onboarding02_Name;